# -*- encoding : utf-8 -*-
require 'sinatra/base'
require 'redis-model-extension'
require 'rack'
require 'rack/session/redis'
require 'rack/flash'
require 'mail'
require File.expand_path("../session_database", __FILE__)
require File.expand_path("../mailer", __FILE__)
require File.expand_path("../user_auth_model", __FILE__)
require './config/mail_config'

module Sinatra
  module SinatraRedisAuth
    def self.registered(app)
      app.use Rack::Session::Redis
      app.use Rack::Flash, :accessorize => [:notice, :error]
      app.set :sinatra_redis_auth_views, File.expand_path('../views/', __FILE__)
      app.set :default_url_after_sign_in, "/"
      app.set :default_url_after_sign_up, "/"
      app.set :default_url_after_sign_out, "/"

      app.before do
        if session[:user]
          @current_user = User.get(:email => session[:user])
        else
          @current_user = nil
        end
      end
      
      app.get '/sign_in' do
        if session[:user]
          redirect options.default_url_after_sign_in
        else
          erb get_view_as_string("sign_in"), :layout => use_layout?
        end
      end

      app.post '/sign_in' do
        if user = User.authenticate(params[:email], params[:password])
          pp user.email
          session[:user] = user.email

          if Rack.const_defined?('Flash')
            flash[:notice] = "Login successful."
          end

          if session[:return_to]
            redirect_url = session[:return_to]
            session[:return_to] = false
            redirect redirect_url
          else
            redirect options.default_url_after_sign_in
          end
        else
          if Rack.const_defined?('Flash')
            flash[:error] = "The email or password you entered is incorrect."
          end
          redirect '/sign_in'
        end
      end

      app.get '/sign_out' do
        session[:user] = nil
        if Rack.const_defined?('Flash')
          flash[:notice] = "Logout successful."
        end
        redirect options.default_url_after_sign_out
      end

      app.get '/sign_up' do
        if session[:user]
          redirect options.default_url_after_sign_up
        else
          erb get_view_as_string("sign_up"), :layout => use_layout?
        end
      end

      app.post '/sign_up' do
        @user = User.new(params)
        if @user.save
          session[:user] = @user.email
          if Rack.const_defined?('Flash')
            flash[:notice] = "Account created."
          end
          if session[:return_to]
            redirect_url = session[:return_to]
            session[:return_to] = false
            redirect session[:return_to]
          else
            redirect options.default_url_after_sign_up
          end
        else
          if Rack.const_defined?('Flash')
            flash[:error] = "There were some problems creating your account: #{@user.errors}."
          end
          redirect '/sign_up?' + hash_to_query_string(params['email'])
        end
      end
      app.get '/password/reset' do
        if session[:user]
          redirect options.default_url_after_sign_in
        else
          erb get_view_as_string("password_reset"), :layout => use_layout?
        end
      end
      app.post '/password/reset' do
        if user = User.get(:email => params[:email])
          user.forgot_password
          flash[:notice] = "We send information for password reset to your email."
          Mailer.send_mail :to => user.email, :link => "http://#{request.host}/password/change/#{user.reset_token}"
          redirect '/sign_in'
        else
          if Rack.const_defined?('Flash')
            flash[:error] = "Email you entered isn't valid."
          end
          erb get_view_as_string("password_reset"), :layout => use_layout?
        end
      end
      app.get '/password/change/:reset_token' do 
        if user = User.get_by_alias(:reset_token, params)
          session[:reset_token] = user.reset_token
          erb get_view_as_string("password_change"), :layout => use_layout? 
        else
          flash[:error] = "Link is not valid!"
          redirect "/"
        end
      end
      app.post '/password/change' do 
        if session[:reset_token]
          if user = User.get_by_alias(:reset_token, :reset_token => session[:reset_token])
            user.change_password params[:password_new]
            user.reset_token = ""
            user.save
            session[:reset_token] = false
            session[:user] = user.email
            flash[:notice] = "Password sucesfully changed."
            redirect "/"
          else
            flash[:error] = "Link is not valid!"
            redirect "/"
          end
        else
          flash[:error] = "Link is not valid!"
          redirect "/"
        end
      end
    end    
  end

  module Helpers
    def hash_to_query_string(hash)
      hash.collect {|k,v| "#{k}=#{v}"}.join('&')
    end

    def login_required
      if @current_user
        return true
      else
        session[:return_to] = request.fullpath
        redirect '/sign_in'
        return false
      end
    end

    def current_user
      if session[:user]
        User.get(:email => session[:user])
      end
    end

    def logged_in?
      !!session[:user]
    end

    def use_layout?
      !request.xhr?
    end

    def get_view_as_string(filename)
      view = File.join(options.sinatra_redis_auth_views, "#{filename}.erb")
      data = ""
      f = File.open(view, "r")
      f.each_line do |line|
        data += line
      end
      return data
    end

  end

  register SinatraRedisAuth
end
