load_path = "#{File.expand_path(File.dirname(__FILE__))}/.."
$LOAD_PATH.unshift(load_path) unless $LOAD_PATH.include?(load_path)

require 'tama'

c = Tama::Tama.new(:test)

[:run_instances,:terminate_instances,:describe_instances,:describe_images,:describe_host_nodes,:describe_instance_specs].each { |method|
  puts "Testing method: #{method}\n"
  puts "Testing method: #{method}\n".gsub(/./) {|s| "-"}
  p c.send(method)
  puts "\n"
}
