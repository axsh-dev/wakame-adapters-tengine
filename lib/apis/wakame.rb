require 'net/http'
require 'net/https'

module Tama
  module Apis
    module InstanceHashBuilder
      # Takes the response from wakame-vdc's /api/instances
      # and builds a hash similar to right_aws' describe_instances
      # but changes the layout of IP addresses
      def build_instances_hash(w_response,account_id)
        w_response.first["results"].map { |inst_map|
          dns_name = inst_map["network"].first["nat_dns_name"] unless inst_map["network"].nil? || inst_map["network"].empty?
          private_dns_name = inst_map["network"].first["dns_name"] unless inst_map["network"].nil? || inst_map["network"].empty?
          # Build the hash of ipaddresses
          unless inst_map["network"].nil? || inst_map["network"].empty?
            ip_address = {}
            inst_map["network"].each { |network|
              ip_address.merge!({network["network_name"] => network["ipaddr"]})
              ip_address.merge!({network["nat_network_name"] => network["nat_ipaddr"]})
            }
            # Remove non existing addresses
            ip_address.delete_if {|k,v| k.nil? || v.nil?}
            
            # Determine private ip address
            private_ip_address = ip_address[self.private_network_name]
            
            # Build the hash of dns names
            dns_name = {}
            inst_map["network"].each { |network|
              dns_name.merge!({network["network_name"] => network["dns_name"]})
              dns_name.merge!({network["nat_network_name"] => network["nat_dns_name"]})
            }
            dns_name.delete_if {|k,v| k.nil?}
            
            # Determine the private dns name
            private_dns_name = dns_name[self.private_network_name]
          end

          # Build the final hash to return
          # This hash is based on right_aws' describe_instances but
          # changes the ip_address format
          {:aws_kernel_id=>"",
          :aws_launch_time=>inst_map["created_at"],
          :tags=>{},
          :aws_reservation_id=>"",
          :aws_owner=>account_id,
          :instance_lifecycle=>"",
          :block_device_mappings=>[{:ebs_volume_id=>"", :ebs_status=>"", :ebs_attach_time=>"", :ebs_delete_on_termination=>false, :device_name=>""}],
          :ami_launch_index=>"",
          :root_device_name=>"",
          :aws_ramdisk_id=>"",
          :aws_availability_zone=>inst_map["host_node"],
          :aws_groups=>inst_map["security_groups"],
          :spot_instance_request_id=>"",
          :ssh_key_name=>inst_map["ssh_key_pair"],
          :virtualization_type=>"",
          :placement_group_name=>"",
          :requester_id=>"",
          :aws_instance_id=>inst_map["id"],
          :aws_product_codes=>[],
          :client_token=>"",
          :private_ip_address=>private_ip_address,
          :architecture=>inst_map["arch"],
          :aws_state_code=>0,
          :aws_image_id=>inst_map["image_id"],
          :root_device_type=>"",
          :ip_address=>ip_address,
          :dns_name=>dns_name,
          :monitoring_state=>"",
          :aws_instance_type=>inst_map["instance_spec_id"],
          :aws_state=>inst_map["state"],
          :private_dns_name=>private_dns_name,
          :aws_reason=>""
          }
        }
      end
    end
    
    class WakameApi
      attr_accessor :host
      attr_accessor :port
      attr_accessor :protocol
      attr_accessor :account
      attr_accessor :private_network_name
      
      Protocols = ["http","https"]
      
      include InstanceHashBuilder
      
      def initialize(account = nil,host = nil, port = nil, protocol = "http",private_network_name = "nw-data")
        raise ArgumentError, "Unknown protocol: #{protocol}. Can be either of the following: #{Protocols.join(",")}" unless Protocols.member?(protocol)
        
        self.host = host
        self.port = port
        self.protocol = protocol
        self.account = account
        
        self.private_network_name = private_network_name
      end
      
      def show_host_nodes(list = [], account = self.account)
        make_request("#{self.web_api}/api/host_nodes",Net::HTTP::Get,account, list)
      end
      alias :describe_host_nodes :show_host_nodes
      
      def show_instance_specs(list = [], account = self.account)
        make_request("#{self.web_api}/api/instance_specs",Net::HTTP::Get,account, list)
      end
      alias :describe_instance_specs :show_instance_specs
      
      # This method could be taken care of by the EC2 adapter but since we
      # want to show ip addresses differently from EC2, we add it to the
      # Wakame part of Tama
      def show_instances(list = [])
        instances = make_request("#{self.web_api}/api/instances",Net::HTTP::Get,account, list)
        build_instances_hash(instances,account)
      end
      alias :describe_instances :show_instances
      
      def make_request(uri,type,accesskey,list = [])
        api = URI.parse(uri)
        
        req = type.new(api.path)
        req.add_field("X_VDC_ACCOUNT_UUID", accesskey)
        
        req.body = ""
        #req.set_form_data(form_data) unless form_data.nil?

        session = Net::HTTP.new(api.host, api.port)
        session.use_ssl = (self.protocol == "https")

        res = session.start do |http|
          http.request(req)
        end
        
        body = JSON.parse(res.body)
        body.first["results"].delete_if {|item| not list.member?(item["id"])} unless list.empty?
        
        body
      end
      
      def web_api
        protocol.to_s + "://" + host.to_s + ":" + port.to_s
      end
    end
    
    class WakameApiTest
      attr_accessor :host_nodes_file
      attr_accessor :show_instance_specs_file
      attr_accessor :show_instances_file
      attr_accessor :private_network_name
      attr_accessor :account
      
      include InstanceHashBuilder
      
      def initialize
        self.host_nodes_file = "#{File.expand_path(File.dirname(__FILE__))}/../../test/test_files/host_nodes.json"
        self.show_instance_specs_file = "#{File.expand_path(File.dirname(__FILE__))}/../../test/test_files/show_instance_specs.json"
        self.show_instances_file = "#{File.expand_path(File.dirname(__FILE__))}/../../test/test_files/describe_instances.json"
        
        self.account = "a-shpoolxx"
        self.private_network_name = "nw-data"
      end
      
      def show_host_nodes(list = [])
        read_file(self.host_nodes_file, list)
      end
      alias :describe_host_nodes :show_host_nodes
      
      def show_instance_specs(list = [])
        read_file(self.show_instance_specs_file, list)
      end
      alias :describe_instance_specs :show_instance_specs
      
      # This method could be taken care of by the EC2 adapter but since we
      # want to show ip addresses differently from EC2, we add it to the
      # Wakame part of Tama
      def show_instances(list = [])
        instances = read_file(self.show_instances_file, list)
        build_instances_hash(instances,self.account)
      end
      alias :describe_instances :show_instances
      
      private
      def read_file(file,list = [])
        File.open(file) { |file|
          res = JSON.parse(file.readlines.join.to_s)
          res.first["results"].delete_if {|item| not list.member?(item["id"])} unless list.empty?
          res
        }
      end
    end
  end
end
