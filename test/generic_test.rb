require '../tama'
include Tama

c = Tama::Tama.new(:test)

[:run_instances,:terminate_instances,:describe_instances,:describe_images,:describe_host_nodes].each { |method|
  puts "Testing method: #{method}\n"
  puts "Testing method: #{method}\n".gsub(/./) {|s| "-"}
  p c.send(method)
  puts "\n"
}
