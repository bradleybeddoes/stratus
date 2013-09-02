require 'rubygems'
require 'bundler'
require 'sinatra'

Bundler.require

require './kickstart_server'

run KickstartServer
