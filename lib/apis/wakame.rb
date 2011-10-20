module Tama
  module Apis
    class WakameApi
      def show_host_nodes
      
      end
      alias :describe_host_nodes :show_host_nodes
    end
    
    class WakameApiTest < WakameApi
      attr_accessor :host_nodes_file
      
      def initialize
        self.host_nodes_file = "#{File.expand_path(File.dirname(__FILE__))}/../../test/test_files/host_nodes.json"
      end
      
      def show_host_nodes
        File.open(self.host_nodes_file) { |file|
          JSON.parse(file.readlines.to_s)
        }
      end
      alias :describe_host_nodes :show_host_nodes
    end
  end
end
