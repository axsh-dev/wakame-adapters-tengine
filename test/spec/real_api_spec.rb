load_path = "#{File.expand_path(File.dirname(__FILE__))}/../.."
$LOAD_PATH.unshift(load_path) unless $LOAD_PATH.include?(load_path)

require 'tama'
require 'spec_helper'

# Api parameters
Account = "a-shpoolxx"

Ec2_host = "192.168.2.22"
Ec2_port = "9005"
Ec2_protocol = "http"

Wakame_host = "127.0.0.1"
Wakame_port = "9001"
Wakame_protocol = "http"

# Run_instance parameters
Image_id = 'wmi-lucid5'
Min = 3
Max = 3
Security_Groups = ['default']
SSH_Key = 'demopair'
User_Data = 'joske'
Addressing_Type = 'public'
Instance_Type = 'is-demospec'
HOST = 'hp-demo1'

# Initialize some global variables we'll be using later
$res = []
$inst_ids = []

describe "TamaController ( Tama.new(#{Account},#{Ec2_host},#{Ec2_port},#{Ec2_protocol},#{Wakame_host},#{Wakame_port},#{Wakame_protocol}) )" do
  before do
    # Initialize our controller
    @tama = Tama::Tama.new(Account,Ec2_host,Ec2_port,Ec2_protocol,Wakame_host,Wakame_port,Wakame_protocol)
  end
  
  it "Should start a number of instances between #{Min} and #{Max}" do
    # Try to start instances
    $res = @tama.run_instances(Image_id,Min,Max,Security_Groups,SSH_Key, User_Data, Addressing_Type, Instance_Type, nil, nil, HOST)
    
    # Check if the correct amount of instances where started
    $res.length.should >= Min
    $res.length.should <= Max
    
    # Prepare the instance ids to be used in further examples
    $inst_ids = $res.map{|i| i[:aws_instance_id]}; 
  end
  
  it "Should describe all instances" do
    insts = @tama.describe_instances
    insts.empty?.should_not be_true
    insts.nil?.should_not be_true
    insts.length.should >= $res.length
  end

  it "Should describe instances #{$inst_ids.join(",")}" do
    insts = @tama.describe_instances($inst_ids)
    
    # Check if we got the correct number of instances
    insts.length.should == $res.length
    
    # Check if the instances we got are the correct ones
    $res.each { |instance|
      $inst_ids.member?(instance[:aws_instance_id]).should be_true
    }
  end
  
  $res.each { |inst_map|
    it "Should describe instance #{inst_map[:aws_instance_id]}" do
      inst = @tama.describe_instances([inst_map[:aws_instance_id]])
      inst.length.should == 1
      inst.first[:aws_instance_id].should == inst_map[:aws_instance_id]
    end
  }
  
  it "Should terminate instances #{$inst_ids.join(",")}" do
    terms = @tama.terminate_instances($inst_ids)
    terms.length.should == $inst_ids.length
    $res.each { |instance|
      $inst_ids.member?(instance[:aws_instance_id]).should be_true
    }
  end
  
  it "Should describe host nodes" do
    hosts = @tama.describe_host_nodes
    hosts.empty?.should be_false
    hosts.nil?.should be_false
  end
  
  it "Should describe instance specs" do
    specs = @tama.describe_instance_specs
    specs.empty?.should be_false
    specs.nil?.should be_false
  end
end
