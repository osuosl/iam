require 'sinatra/base'
require_relative 'environment'
require_relative 'scheduler'

# IAM - a resource usage metric collection and reporting system
class Iam < Sinatra::Base
  set :show_exceptions, :after_handler
  # require the models, but make sure to do it after the test db is migrated
  require 'models'

  (Dir['plugins/*/plugin.rb'] + Dir['routes/*.rb']).each do |file|
    require file
  end

  register Sinatra::MainRoutes
  register Sinatra::ClientRoutes
  register Sinatra::ProjectRoutes
  register Sinatra::NodeRoutes

  run! unless ENV['RACK_ENV'] == 'test'
end
