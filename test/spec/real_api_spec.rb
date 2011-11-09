load_path = "#{File.expand_path(File.dirname(__FILE__))}/../.."
$LOAD_PATH.unshift(load_path) unless $LOAD_PATH.include?(load_path)

require 'spec_helper'
require 'tama'

require 'yaml'
config = YAML.load_file File.expand_path('../config.yml', __FILE__)

describe "TamaController" do
  tama = Tama::Tama.new(config["Account"],config["Ec2_host"],config["Ec2_port"],config["Ec2_protocol"],config["Wakame_host"],config["Wakame_port"],config["Wakame_protocol"])
  res = tama.run_instances(config["Image_id"],config["Min"],config["Max"],config["Security_Groups"].values,config["SSH_Key"], config["User_Data"], config["Addressing_Type"], config["Instance_Type"], nil, nil, config["HOST"])
  
  describe "run_instances" do
    it_should_behave_like "run_instances", res, config
    it_should_behave_like "run_instances return values", res, config
  end
  
  describe "describe_instances" do
    @desc_res = tama.describe_instances(res.map{|i| i[:aws_instance_id]})
    it_should_behave_like "run_instances return values", @desc_res, config
    it_should_behave_like "describe_instances return values", @desc_res, config
  end
  
  describe "terminate_instances" do
    @uuids = res.map{|i| i[:aws_instance_id]}
    it_should_behave_like "terminate_instances", tama, @uuids
  end
  
  [:describe_host_nodes,:describe_instance_specs].each { |method|
    describe "#{method}" do
      it_should_behave_like "wakame describe method", tama, method, config[method.to_s]
    end
  }
end
