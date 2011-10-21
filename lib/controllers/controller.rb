# -*- coding: utf-8 -*-

require 'rubygems'
require 'right_aws'

module Tama
  module Controllers
    A = Tama::Apis

    # A Controller just passes any method calls it gets to its api
    # The api can be whatever class you want it to be.
    #
    # A Controller can contain one api or an array of apis. In case of an array
    # TamaController checks each of its apis in turn and executes the method
    # on the first API that supports it
    class Controller
      attr_accessor :api
      
      def initialize(api)
        self.api = api
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
    
    # The TamaController is a controller that has two apis
    # A RightAws::Ec2 object for handling Amazon Ec2 requests and
    # a WakameApi for handling requests to Wakame-vdc
    class TamaController < Controller
      def initialize(access_key,ec2_host,ec2_port,ec2_protocol,wakame_host,wakame_port,wakame_protocol)
        super([
          RightAws::Ec2.new(access_key,"dummy",{:server => ec2_host,:port => ec2_port,:protocol => ec2_protocol}),
          A::WakameApi.new(access_key,wakame_host,wakame_port,wakame_protocol)
        ])
      end
    end
    
    # TamaTestController does the same as TamaController but
    # reads output from a file on disk. It doesn't actually make
    # any requests to Wakame or Ec2
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
