require 'sinatra/base'
require File.expand_path '../environment.rb', __FILE__

# IAM - a resource usage metric collection and reporting system
class Iam < Sinatra::Base
  # require the models, but make sure to do it after the test db is migrated
  require 'models'

  # load up all the plugins
  plugin_dirs = File.dirname(__FILE__) + '/plugins/**/'

  Rake::FileList[plugin_dirs + "plugin.rb"].each { |file|
    require file
  }

  ##
  # static Pages
  ##

  get '/' do
    'Hello'
  end

  ##
  # Clients
  ##

  get '/clients' do
    @clients = Client.each { |x| p x.name }
    erb :'clients/index'
  end

  get '/clients/new' do
    erb :'clients/new'
  end

end
