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
Min = 3
Max = 3
Security_Groups = ['default']
SSH_Key = 'demopair'
User_Data = 'joske'
Addressing_Type = 'public'
Instance_Type = 'is-demospec'
HOST = 'hp-demo1'

def usage
  "Usage:
  ruby real_test.rb [command] [options]
  
Commands:
  run_instances                     # Start a new instance using the data defined in this file.
  describe_instances [instance_ids] # Show the alive instances.
  terminate_instances instance_ids  # Terminate alive instances.
  describe_images                   # Describes images in the database.
  describe_host_nodes               # Describes host nodes in the database
  describe_instance_specs           # Describes instance specs in the database"
end

if ARGV[0] == "help" || ARGV[0] == "--help" || ARGV[0] == "-h"
  puts usage
  exit 0
end

c = Tama::Tama.new(Account,Ec2_host,Ec2_port,Ec2_protocol,Wakame_host,Wakame_port,Wakame_protocol)

if ARGV.empty?
  [:run_instances,:terminate_instances,:describe_instances,:describe_images,:describe_host_nodes,:describe_instance_specs].each { |method|
    puts "Testing method: #{method}\n"
    puts "Testing method: #{method}\n".gsub(/./) {|s| "-"}
    p case method
      when :run_instances then c.send(method,Image_id,Min,Max,Security_Groups,SSH_Key, User_Data, Addressing_Type, Instance_Type, nil, nil, HOST)
      when :terminate_instances then c.send(method,Instances_to_terminate)
      else c.send(method)
    end
    puts "\n"
  }
elsif ARGV[0] == "run_instances"
  p c.run_instances(Image_id,Min,Max,Security_Groups,SSH_Key, User_Data, Addressing_Type, Instance_Type, nil, nil, HOST)
else
  p c.send(ARGV[0],ARGV.slice(1..ARGV.length) || [])
end
