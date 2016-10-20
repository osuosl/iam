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

  # sinatra configs
  enable :method_override
  set :port, 4567
  set :bind, '0.0.0.0'
  set :root, File.dirname(__FILE__)
  set :public_folder, proc { File.join(root, 'static') }

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

  # TODO: replace the settings file with a more robust yml solution
  env_file = 'env'
  config = {}

  if File.file?(env_file)
    File.open(env_file, 'r') do |f|
      f.each_line do |line|
        puts line
        option = line.split(' ')
        puts option
        config[option[0]] = option[1].strip
      end
    end
  else
    puts "Configuration file './env' not found"
    no_conf_file = true
  end

  # Application Dataase settings
  if ENV['DB_URL']
    set :database, ENV['DB_URI']
  else
    if no_conf_file
      abort('No conf file and not all settings are in env variables, dying')
    end
    set :database, config['db_url']
  end

  set :DB, Sequel.connect(settings.database) if defined? settings.database

  # CACHE settings
  set :cache_file, ENV['CACHE_FILE'] ||= config['cache_file']

  # Logging
  set :log_file_path, ENV['LOG_FILE_PATH'] ||= config['log_file_path']

  # Ganeti Collector settings
  if ENV['GANETI_CLUSTERS']
    ganeti_clusters = ENV['GANETI_CLUSTERS'].split(',')
  else
    ganeti_clusters = config['ganeti_clusters'].split(',')
  end

  set :ganeti_collector_clusters, ganeti_clusters

  # Database collector settings
  # TODO: allow multiple mysql and pg databases
  set :db_collector_pg_user, ENV['DB_COLLECTOR_PG_USER'] ||=
    config['db_collector_pg_user']
  set :db_collector_pg_pw, ENV['DB_COLLECTOR_PG_PW'] ||=
    config['db_collector_pg_pw']
  set :db_collector_pg_host, ENV['DB_COLLECTOR_PG_HOST'] ||=
    config['db_collector_pg_host']
  set :db_collector_mysql_user, ENV['DB_COLLECTOR_MYSQL_USER'] ||=
    config['db_collector_mysql_user']
  set :db_collector_mysql_pw, ENV['DB_COLLECTOR_MYSQL_PW'] ||=
    config['db_collector_mysql_pw']
  set :db_collector_mysql_host, ENV['DB_COLLECTOR_MYSQL_HOST'] ||=
    config['db_collector_mysql_host']
end
