# -*- coding: utf-8 -*-

module Tama
  module Controllers
    A = Tama::Apis
  
    class Controller
      attr_accessor :api
      
      def initialize(api)
        self.api = api
      end
      
      def pass_method(method_name)
        self.api.send(method_name)
      end
    end
    
    class TamaController < Controller
      def initialize
        super([A::Ec2Api.new, A::WakameApi.new])
      end
      
      def pass_method(method_name)
        if self.api.is_a? Array
          index = 0
          begin
            self.api[index].send(method_name)
          rescue NoMethodError => e
            index += 1
            raise if index == self.api.length
            retry
          end
        else
          api.send(method_name)
        end
      end
    end
    
    class TamaTestController < TamaController
      def initialize
        self.api = [A::Ec2ApiTest.new,A::WakameApiTest.new]
      end
    end
    
    class ControllerFactory
      def self.create_controller(type = nil)
        case type
          when :test || "test" then
            c = TamaTestController.new
            c
          else TamaController.new
        end
      end
    end
  end
end
