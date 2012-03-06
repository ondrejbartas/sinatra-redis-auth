# -*- encoding : utf-8 -*-
require 'sinatra'
require 'sinatra/base'
require 'erb'
require 'yaml'
require '../lib/sinatra-redis-auth'
require './user'

class ExampleApp < Sinatra::Base
  register Sinatra::SinatraRedisAuth
  set :views, File.dirname(__FILE__) + '/views'

  get "/" do
    erb :index
  end

  get "/protected_page" do
    login_required
    erb :protected_page
  end

end
