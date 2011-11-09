require 'rubygems'
require 'rspec'
require 'time'


shared_examples_for "run_instances" do |result,args|
  it "Should have started a number of instances between #{args["Min"]} and #{args["Max"]}" do
    result.length.should >= args["Min"]
    result.length.should <= args["Max"]
  end
end

shared_examples_for "run_instances return values" do |result,args|
  result.each { |inst_map|
    it "#{inst_map[:aws_instance_id]} should have a proper time value set for :aws_launch_time" do
      Time.parse(inst_map[:aws_launch_time]).utc.xmlschema == inst_map[:aws_launch_time]
    end
    
    it "#{inst_map[:aws_instance_id]} should have #{args["Account"]} set as :aws_owner" do
      inst_map[:aws_owner].should == args["Account"]
    end
    
    it "#{inst_map[:aws_instance_id]} should have #{args["Security_Groups"].keys.inspect} set as :aws_groups" do
      inst_map[:aws_groups].sort.should == args["Security_Groups"].keys.sort
    end
    
    it "#{inst_map[:aws_instance_id]} should have 0 set as :aws_state_code" do
      inst_map[:aws_state_code].should == 0
    end
    
    it "#{inst_map[:aws_instance_id]} should have #{args["Image_id"]} set as :aws_image_id" do
      inst_map[:aws_image_id].should == args["Image_id"]
    end
    
    it "#{inst_map[:aws_instance_id]} should have #{args["Instance_Type"]} set as :aws_instance_type" do
      inst_map[:aws_instance_type].should == args["Instance_Type"]
    end
    
    #it "#{inst_map[:aws_instance_id]} should have one of #{possible_states.join(",")} set as :aws_state" do
    
    #end
  }
end

shared_examples_for "describe_instances return values" do |result,args|
  before(:all) do
    @uuids = result.map {|i| i[:aws_instance_id]}
  end
  
  #it "Should have described #{result.length} instances" do
    #result.length.should == result.length
  #end
  
  result.each { |inst_map|
    #it "#{inst_map[:aws_instance_id]} should have #{args["HOST"]} set as :aws_availability_zone" do
      #inst_map[:aws_availablity_zone].should == args["HOST"]
    #end
    
    it "#{inst_map[:aws_instance_id]} should have #{args["SSH_Key"]} set as :ssh_key_name" do
      inst_map[:ssh_key_name].should == args["SSH_Key"]
    end
    
    #it "#{inst_map[:aws_instance_id]} should have #{args[:arch]} set as :architecture" do
      #inst_map[:architecture].should == args[:arch]
    #end
  }
end

shared_examples_for "terminate_instances" do |tama,uuids|
  it "should terminate instances #{uuids.join(",")}" do
    res = tama.terminate_instances(uuids)
    
    res.length.should == uuids.length
    res.map {|i| i[:aws_instance_id]}.sort.should == uuids.sort
  end
end

shared_examples_for "describe_host_nodes" do |tama,node_ids|
  it "should describe all host nodes" do
    res = tama.describe_host_nodes
    # We don't know how many host nodes there are and what their values are so
    # we just check if we got a proper reply with a results array in it
    res.nil?.should be_false
    res.empty?.should be_false
    res.first["results"].class.should == Array
  end
  
  it "should describe #{node_ids.join(",")}" do
    res = tama.describe_host_nodes(node_ids)
    res.first["results"].length.should == node_ids.length
    res.first["results"].map {|node| node["uuid"]}.sort.should == node_ids.sort
  end
end

#shared_examples_for "describe_images" do |result,args|
  #result.each { |img_map|
    #it "#{img_map[:aws]}"
  #}
#end
