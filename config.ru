require 'rubygems'
require 'bundler'
require 'sinatra'
require 'rack'
require 'carrierwave'
require 'carrierwave/datamapper'
require './app'


set :root, Pathname(__FILE__).dirname
set :environment, :development
set :run, false

run Sinatra::Application