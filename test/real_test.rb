load_path = "#{File.expand_path(File.dirname(__FILE__))}/.."
$LOAD_PATH.unshift(load_path) unless $LOAD_PATH.include?(load_path)

require 'tama'

Account = "a-shpoolxx"

Ec2_host = "192.168.2.22"
Ec2_port = "9005"
Ec2_protocol = "http"

Wakame_host = "127.0.0.1"
Wakame_port = "9001"
Wakame_protocol = "http"

#Put the instances you want to terminate in this array
Instances_to_terminate = []

#Arguments for run_instances
Image_id = 'wmi-lucid5'
Min = 1
Max = 1
Security_Groups = ['default']
SSH_Key = 'demopair'
User_Data = 'joske'
Addressing_Type = 'public'
Instance_Type = 'is-demospec'

c = Tama::Tama.new(Account,Ec2_host,Ec2_port,Ec2_protocol,Wakame_host,Wakame_port,Wakame_protocol)

[:run_instances,:terminate_instances,:describe_instances,:describe_images,:describe_host_nodes].each { |method|
  puts "Testing method: #{method}\n"
  puts "Testing method: #{method}\n".gsub(/./) {|s| "-"}
  p case method
    when :run_instances then c.send(method,Image_id,Min,Max,Security_Groups,SSH_Key, User_Data, Addressing_Type, Instance_Type)
    when :terminate_instances then c.send(method,Instances_to_terminate)
    else c.send(method)
  end
  puts "\n"
}
