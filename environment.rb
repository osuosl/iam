## This file defines various environments and associates settings with them
require 'sinatra/base'

# The IAM working environment
# require libraries, setup databases and do other app-wide setup here
class Iam < Sinatra::Base
  # make everything relative to where we are now
  $LOAD_PATH << File.expand_path('../', __FILE__)

  # environment is development unless otherwise set
  ENV['RACK_ENV'] ||= 'development'

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
  require 'yaml'
  require_relative 'lib/util.rb'

  # Test stuff
  if ENV['RACK_ENV'] == 'development' || ENV['RACK_ENV'] == 'testing'
    require 'sqlite3'
    # testing stuff
    require 'rspec'
    require 'rack/test'
    require 'factory_girl'
  end

  # Bundler.require(...) requires all gems necessary regardless of
  # environment (:default) in addition to all environment-specific gems.
  Bundler.require(:default, Sinatra::Application.environment)

  # get all the settings, but only if we're not in testing
  if ENV['RACK_ENV'] == 'development' || ENV['RACK_ENV'] == 'production'
    env_file = 'env.yml'
    config = {}
    if File.file?(env_file)
      config_opts = YAML.load_file(env_file)
      config_opts['config'].each { |key, value| config[key] = value }
    else
      puts "Configuration file #{env_file} not found"
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
      ganeti_clusters = config['ganeti_clusters']
    end

    set :ganeti_collector_clusters, ganeti_clusters

    # Database collector settings
    # if this is set in the environemt, split out the tring into an
    # array of hashes (hackarific)
    # DB_COLLECTOR_MYSQL_DBS=user:pass:host,user2:pass2:host2...
    if ENV['DB_COLLECTOR__DBS']
      db_collector_mysql_dbs = []
      ENV['DB_COLLECTOR_DBS'].split(',').each | db |
        db.split(':').each { |key, value| db_hash[key] = value }
      db_collector_mysql_dbs.append(db_hash)
    else
      db_collector_mysql_dbs = config['db_collector_dbs']
    end

    set :db_collector_mysql_dbs, db_collector_mysql_dbs

    # Testing variables (see also .travis.yml)
    set :test_mysql_db, ENV['TEST_MYSQL_DB'] ||= config['test_mysql_db']
    set :test_mysql_pass, ENV['TESTING_MYSQL_PASS'] ||= config['test_mysql_db']
    set :test_mysql_root_pass, ENV['TEST_MYSQL_ROOT_PASS'] ||=
      config['test_mysql_root_pass']
    set :test_mysql_host, ENV['TEST_MYSQL_HOST'] ||= config['test_mysql_host']
    set :test_mysql_user, ENV['TEST_MYSQL_USER'] ||= config['test_mysql_user']
  end
end
