# -*- coding: utf-8 -*-

require 'rubygems'
require 'right_aws'

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
      def initialize(access_key,ec2_host,ec2_port,ec2_protocol,wakame_host,wakame_port,wakame_protocol)
        super([
          RightAws::Ec2.new(access_key,nil,{:server => ec2_host,:port => ec2_port,:protocol => ec2_protocol}),
          A::WakameApi.new(access_key,wakame_host,wakame_port,wakame_protocol)
        ])
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
            TamaTestController.new
          else TamaController.new(*args)
        end
      end
    end
  end
end
