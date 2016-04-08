## This file defines various environments and associates settings with them

$: << File.expand_path('../', __FILE__)

# basic Ruby stuff

require "rubygems"
require "bundler/setup"

# Sinatra stuff (note we are requiring base, this is a modular app)
require "sinatra/base"

# Iam stuff
require 'app'

# Database stuff

require 'sequel'
require 'sqlite3'

# migrations are extensions that have to be loaded
Sequel.extension :migration, :core_extensions

# testing stuff
require 'rspec'
require 'rack/test'
require 'factory_girl'

# Bundler.require(...) requires all gems necessary regardless of
#   environment (:default) in addition to all environment-specific gems.
Bundler.require(:default, Sinatra::Application.environment)
