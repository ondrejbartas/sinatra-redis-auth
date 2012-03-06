# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "sinatra-redis-auth"
  gem.homepage = "http://github.com/ondrejbartas/sinatra-redis-auth"
  gem.license = "MIT"
  gem.summary = %Q{Sinatra authentification with saving user data to redis}
  gem.description = %Q{Sinatra authentification with saving user data to redis}
  gem.email = "ondrej@bartas.cz"
  gem.authors = ["Ondrej Bartas"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

namespace :'sinatra-redis-auth' do
  task :install do
    FileUtils.mkdir_p('config') unless File.exists?('config')
    ["redis_config.yml", "sinatra_mailer.rb"].each do |name|
      unless File.exists?("config/#{name}")
        puts "created config file: 'config/#{name}'"
        FileUtils.cp(File.join(File.dirname(__FILE__),"../config/#{name}.example"), "config/#{name}")
      end
    end
  end
end