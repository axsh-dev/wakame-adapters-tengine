# -*- coding: utf-8 -*-

require 'rubygems'

load_path = "#{File.expand_path(File.dirname(__FILE__))}/lib"
$LOAD_PATH.unshift(load_path) unless $LOAD_PATH.include?(load_path)

require 'apis/ec2'
require 'apis/wakame'
require 'controllers/controller'
