# -*- coding: utf-8 -*-

module Tama
  module Controllers
    A = Tama::Apis
  
    class Controller
      attr_accessor :api
      
      def initialize(api)
        self.api = api
      end
      
      def method_missing(method_name,*args)
        self.api.send(method_name)
      end
    end
    
    class TamaController < Controller
      def initialize
        super([A::Ec2Api.new, A::WakameApi.new])
      end
      
      def method_missing(method_name,*args)
        if self.api.is_a? Array
          index = 0
          begin
            self.api[index].send(method_name,*args)
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
      def self.create_controller(*args)
        case 
          when args.first == :test || args.first == "test" then
            c = TamaTestController.new
            c
          else TamaController.new
        end
      end
    end
  end
end
