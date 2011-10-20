require '../tama'

c = Tama::Controllers::ControllerFactory.create_controller(:test)

[:run_instances,:terminate_instances,:describe_instances,:describe_images,:describe_host_nodes].each { |method|
  puts "Testing method: #{method}\n"
  puts "Testing method: #{method}\n".gsub(/./) {|s| "-"}
  p c.pass_method(method)
  puts "\n"
}
