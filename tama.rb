# -*- coding: utf-8 -*-

require 'rubygems'

load_path = "#{File.expand_path(File.dirname(__FILE__))}/lib"
$LOAD_PATH.unshift(load_path) unless $LOAD_PATH.include?(load_path)

require 'apis/ec2'
require 'apis/wakame'
require 'controllers/controller'

module Tama
  # Just a wrapper class for our controller to make the syntax a bit more beautiful ^_~
  class Tama
    def initialize(*args)
      @controller = Controllers::ControllerFactory.create_controller(*args)
    end
    
    def method_missing(m,*args)
      @controller.send(m,*args)
    end
  end
end
