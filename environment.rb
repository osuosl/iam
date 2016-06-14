## This file defines various environments and associates settings with them
require 'sinatra/base'

# The IAM working environment
# require libraries, setup databases and do other app-wide setup here
class Iam < Sinatra::Base
  # make everything relative to where we are now
  $LOAD_PATH << File.expand_path('../', __FILE__)

  # environment is development unless otherwise set
  ENV['RACK_ENV'] ||= 'development'

  env = ENV['RACK_ENV'].to_sym

  require 'bundler'

  # basic Ruby stuff
  require 'rubygems'
  require 'bundler/setup'

  # Database stuff
  require 'sequel'
  require 'sinatra/sequel'
  Sequel.extension :migration, :core_extensions

  # Other tools we use
  require 'net/http'
  require 'uri'
  require 'openssl'
  require 'json'
  require_relative 'lib/util.rb'

  # Test stuff
  if env == 'development' || env == 'test'
    require 'sqlite3'
    # testing stuff
    require 'rspec'
    require 'rack/test'
    require 'factory_girl'
  end

  # Bundler.require(...) requires all gems necessary regardless of
  # environment (:default) in addition to all environment-specific gems.
  Bundler.require(:default, Sinatra::Application.environment)

  configure :production do
    set :database, ENV['DB_URI'] ||= 'sqlite:///tmp/production.sqlite'
  end
  configure :development do
    set :database, ENV['DB_URI'] ||= 'sqlite:///tmp/development.sqlite'
  end

  configure :test do
    set :database, 'sqlite:/'
  end

  set :DB, Sequel.connect(settings.database) if defined? settings.database
end
