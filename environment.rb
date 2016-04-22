## This file defines various environments and associates settings with them
require "sinatra/base"

class Iam < Sinatra::Base
	# make everything relative to where we are now
	$: << File.expand_path('../', __FILE__)

	# environment is development unless otherwise set
	ENV['RACK_ENV'] ||= 'development'

	env = ENV['RACK_ENV'].to_sym

	require 'bundler'

	# basic Ruby stuff
	require "rubygems"
	require "bundler/setup"

	# Sinatra stuff (note we are requiring base, this is a modular app)
	#require 'sinatra'
	#require "sinatra/base"

	# Iam stuff
	#require 'app'

	# Database stuff
	require 'sequel'
	require 'sinatra/sequel'
	Sequel.extension :migration, :core_extensions

	# Other tools we use
	require 'net/http'
	require 'uri'
	require 'openssl'
	require 'json'
	require 'redis'

	# Test stuff
	if :env == 'development' or :env == 'test'
	  require 'sqlite3'
	  # testing stuff
	  require 'rspec'
	  require 'rack/test'
	  require 'factory_girl'
	end

	# Bundler.require(...) requires all gems necessary regardless of
	#   environment (:default) in addition to all environment-specific gems.
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

  if defined? settings.database
    set :DB, Sequel.connect(settings.database)
  end

end