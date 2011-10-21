# -*- coding: utf-8 -*-

require 'rubygems'
require 'json'

module Tama
  module Apis
    
    # Reads JSON files and returns Hash maps similar to right_aws
    class Ec2ApiTest #< ec2Api
      attr_accessor :describe_instances_file
      attr_accessor :describe_images_file
      attr_accessor :run_instances_file
      attr_accessor :terminate_instances_file
      
      def initialize
        self.terminate_instances_file = "#{File.expand_path(File.dirname(__FILE__))}/../../test/test_files/terminate_instances.json"
        self.describe_images_file = "#{File.expand_path(File.dirname(__FILE__))}/../../test/test_files/describe_images.json"
        self.describe_instances_file = "#{File.expand_path(File.dirname(__FILE__))}/../../test/test_files/describe_instances.json"
        self.run_instances_file = "#{File.expand_path(File.dirname(__FILE__))}/../../test/test_files/run_instances.json"
      end
      
      def describe_instances(list=[])
        File.open(self.describe_instances_file) { |file|
          res = JSON.parse(file.readlines.to_s).first["results"]
          res.delete_if {|item| not list.member?(item["id"])} unless list.empty?
          res.map { |inst_map|
            dns_name = inst_map["network"].first["nat_dns_name"] unless inst_map["network"].nil? || inst_map["network"].empty?
            private_dns_name = inst_map["network"].first["dns_name"] unless inst_map["network"].nil? || inst_map["network"].empty?
            ip_address = inst_map["vif"].first["ipv4"]["nat_address"] unless inst_map["vif"].nil? || inst_map["vif"].empty? || inst_map["vif"].first["ipv4"].nil?
            private_ip_address = inst_map["vif"].first["ipv4"]["address"] unless inst_map["vif"].nil? || inst_map["vif"].empty? || inst_map["vif"].first["ipv4"].nil?
            {:aws_kernel_id=>"",
            :aws_launch_time=>inst_map["created_at"],
            :tags=>{},
            :aws_reservation_id=>"",
            :aws_owner=>inst_map["account_id"],
            :instance_lifecycle=>"",
            :block_device_mappings=>[{:ebs_volume_id=>"", :ebs_status=>"", :ebs_attach_time=>"", :ebs_delete_on_termination=>false, :device_name=>""}],
            :ami_launch_index=>"",
            :root_device_name=>"",
            :aws_ramdisk_id=>"",
            :aws_availability_zone=>inst_map["host_node"],
            :aws_groups=>inst_map["netfilter_group_id"],
            :spot_instance_request_id=>"",
            :ssh_key_name=>"",
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
        }
      end
      
      def describe_images(list=[], image_type=nil)
        File.open(self.describe_images_file) { |file|
          #p JSON.parse(file.readlines.to_s)
          res = JSON.parse(file.readlines.to_s).first["results"]
          res.delete_if {|item| not list.member?(item["id"])} unless list.empty?
          res.map { |img_map|
            {:root_device_name=>"",
             :aws_ramdisk_id=>"",
             :block_device_mappings=>[{:ebs_snapshot_id=>"",
             :ebs_volume_size=>0,
             :ebs_delete_on_termination=>false,
             :device_name=>""}],
             :aws_is_public=>img_map["is_public"],
             :virtualization_type=>"",
             :image_owner_alias=>"",
             :aws_id=>img_map["uuid"],
             :aws_architecture=>img_map["arch"],
             :root_device_type=>"",
             :aws_location=>img_map["source"],
             :aws_image_type=>"",
             :name=>"",
             :aws_state=>img_map["state"],
             :description=>img_map["description"],
             :aws_kernel_id=>"",
             :tags=>{},
             :aws_owner=>img_map["account_id"]
            }
          }
        }
      end
      
      # The arguments here are just placeholders to match the real
      # run_instances method. The output is read from a file as usual.
      def run_instances(image_id=nil, min_count=nil, max_count=nil, group_ids=nil, key_name=nil, user_data='', addressing_type = nil, instance_type = nil, kernel_id = nil, ramdisk_id = nil, availability_zone = nil, block_device_mappings = nil)
        File.open(self.run_instances_file) { |file|
          JSON.parse(file.readlines.to_s).map { |inst_map|
            dns_name = inst_map["network"].first["nat_dns_name"] unless inst_map["network"].nil? || inst_map["network"].empty?
            private_dns_name = inst_map["network"].first["dns_name"] unless inst_map["network"].nil? || inst_map["network"].empty?
            {:aws_launch_time=>inst_map["created_at"],
            :tags=>{},
            :aws_reservation_id=>"",
            :aws_owner=>inst_map["account_id"],
            :ami_launch_index=>"",
            :aws_availability_zone=>"",
            :aws_groups=>inst_map["netfilter_group_id"],
            :ssh_key_name=>inst_map["ssh_key_pair"],
            :virtualization_type=>"",
            :placement_group_name=>"",
            :aws_instance_id=>inst_map["id"],
            :aws_product_codes=>[],
            :client_token=>"",
            :aws_state_code=>0,
            :aws_image_id=>inst_map["image_id"],
            :dns_name=>dns_name,
            :aws_instance_type=>inst_map["instance_spec_id"],
            :aws_state=>inst_map["state"],
            :private_dns_name=>private_dns_name,
            :aws_reason=>""}
          }
        }
      end
      
      def terminate_instances(list=[])
        File.open(self.terminate_instances_file) { |file|
          JSON.parse(file.readlines.to_s).map { |instance_id|
            {:aws_shutdown_state      => nil,
             :aws_instance_id         => instance_id,
             :aws_shutdown_state_code => nil,
             :aws_prev_state          => nil,
             :aws_prev_state_code     => nil}
          }
        }
      end
    end
  end
end
