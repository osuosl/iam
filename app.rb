require File.expand_path("../environment", __FILE__)

# Ruby
require 'rubygems'
require 'bundler'

Bundler.require

$: << File.expand_path('../', __FILE__)

# Sinatra
require 'sinatra/base'

class Iam < Sinatra::Base

  # configure this app - TODO - move to separate file
  # set RACK_ENV environment variable to select the environment
  configure :production do
    set :database, 'sqlite://tmp/development.sqlite'
  end
  configure :development do
    set :database, 'sqlite://tmp/development.sqlite'
  end
  configure :test do
    set :database, 'sqlite:/'
  end

  db = Sequel.connect(settings.database)
  
  # this really belongs in sepc helper, but the db connection scope
  # is confusing
  if :test
    Sequel::Migrator.run(db, "migrations")
  end

  # Iam
  # require the models, but make sure to do it after the test db is migrated
  require 'models'

  # load up all the plugins
  Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each {|file| require file }

  ##
  # static Pages
  ##

  get '/' do
    "Hello"
  end

  ##
  # Clients
  ##

  get '/clients' do
    @clients = Client.each{|x| p x.client_name}
    erb :"clients/index"
  end

  get '/clients/new' do
    erb :"clients/new"
  end
end
