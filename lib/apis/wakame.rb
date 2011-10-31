require 'net/http'

module Tama
  module Apis
    class WakameApi
      attr_accessor :host
      attr_accessor :port
      attr_accessor :protocol
      attr_accessor :account
      
      Protocols = ["http","https"]
      
      def initialize(account = nil,host = nil, port = nil, protocol = "http")
        raise ArgumentError, "Unknown protocol: #{protocol}. Can be either of the following: #{Protocols.join(",")}" unless Protocols.member?(protocol)
        
        self.host = host
        self.port = port
        self.protocol = protocol
        self.account = account
      end
      
      def show_host_nodes(account = self.account)
        res = make_request("#{self.web_api}/api/host_pools",Net::HTTP::Get,account)
        JSON.parse res.body
      end
      alias :describe_host_nodes :show_host_nodes
      
      def make_request(uri,type,accesskey,form_data = nil)
        api = URI.parse(uri)
        
        req = type.new(api.path)
        req.add_field("X_VDC_ACCOUNT_UUID", accesskey)
        
        req.body = ""
        req.set_form_data(form_data) unless form_data.nil?

        res = Net::HTTP.new(api.host, api.port).start do |http|
          http.request(req)
        end
        
        res
      end
      
      def web_api
        protocol.to_s + "://" + host.to_s + ":" + port.to_s
      end
    end
    
    class WakameApiTest
      attr_accessor :host_nodes_file
      attr_accessor :show_instance_specs_file
      
      def initialize
        self.host_nodes_file = "#{File.expand_path(File.dirname(__FILE__))}/../../test/test_files/host_nodes.json"
        self.show_instance_specs_file = "#{File.expand_path(File.dirname(__FILE__))}/../../test/test_files/show_instance_specs.json"
      end
      
      def show_host_nodes(list = [])
        read_file(self.host_nodes_file, list)
      end
      alias :describe_host_nodes :show_host_nodes
      
      def show_instance_specs(list = [])
        read_file(self.show_instance_specs_file, list)
      end
      alias :describe_instance_specs :show_instance_specs
      
      private
      def read_file(file,list = [])
        File.open(file) { |file|
          res = JSON.parse(file.readlines.to_s)
          res.first["results"].delete_if {|item| not list.member?(item["id"])} unless list.empty?
          res
        }
      end
    end
  end
end
