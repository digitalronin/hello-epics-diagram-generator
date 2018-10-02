#!/usr/bin/env ruby

require 'bundler/setup'
require 'sinatra/base'
require 'trello'

class Server < Sinatra::Base
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == ENV.fetch('USERNAME') && password == ENV.fetch('PASSWORD')
  end

  get '/' do
    erb :index
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end

