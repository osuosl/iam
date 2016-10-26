## This file defines various environments and associates settings with them
require 'sinatra/base'

# The IAM working environment
# require libraries, setup databases and do other app-wide setup here
class Iam < Sinatra::Base
  # make everything relative to where we are now
  $LOAD_PATH << File.expand_path('../', __FILE__)

  # load db credentials from db_creds.txt to the ENV
  env_file = 'db_creds.txt'
  File.open(env_file, 'r') do |f|
    f.each_line do |line|
      creds = line.split('=')
      ENV[creds[0]] = creds[1].delete("\n")
    end
  end

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
  if ENV['RACK_ENV'] == 'development' || ENV['RACK_ENV'] == 'test'
    require 'sqlite3'
    # testing stuff
    require 'rspec'
    require 'rack/test'
    require 'factory_girl'
  end

  # if we're testing, set up all the settings we need for that
  # TODO: should these be set in each spec test? Probably, and we should
  # clean up those test files after, but this will be ok for now
  if ENV['RACK_ENV'] == 'test'
    test_db = 'test.sqlite'
    cachefile = 'testcache'
    logfile = 'testlog'
    File.delete(test_db) if File.file?(test_db)
    File.delete(cachefile) if File.file?(cachefile)
    File.delete(logfile) if File.file?(logfile)

    ENV['DB_URL'] = "sqlite://#{test_db}"
    ENV['CACHE_FILE'] = cachefile
    ENV['LOG_FILE_PATH'] = logfile
    ENV['GANETI_CLUSTERS'] = 'ganeti'

    # set some fake databases so the collector tests work
    set :db_collector_dbs, [{ 'type' => 'mysql', 'user' => 'listener',
                              'password' => '', 'host' => 'localhost' }]
  end

  # Bundler.require(...) requires all gems necessary regardless of
  # environment (:default) in addition to all environment-specific gems.
  Bundler.require(:default, Sinatra::Application.environment)

  # Get all the settings. If they are set in the environment, use that, if not
  # see if there is an env.yml file. If neither are set, die.
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
    set :database, ENV['DB_URL']
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
  ganeti_clusters = if ENV['GANETI_CLUSTERS']
                      ENV['GANETI_CLUSTERS'].split(',')
                    else
                      config['ganeti_clusters']
                    end

  set :ganeti_collector_clusters, ganeti_clusters

  # Database collector settings
  # if this is set in the environemt, split out the tring into an
  # array of hashes (hackarific)
  # DB_COLLECTOR_MYSQL_DBS=user:pass:host,user2:pass2:host2...
  if ENV['DB_COLLECTOR__DBS']
    db_collector_dbs = []
    ENV['DB_COLLECTOR_DBS'].split(',').each | db |
      db.split(':').each { |key, value| db_hash[key] = value }
    db_collector_dbs.append(db_hash)
  else
    db_collector_dbs = config['db_collector_dbs']
  end

  set :db_collector_dbs, db_collector_dbs
end
