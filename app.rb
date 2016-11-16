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

  puts "yo"

  # initialize the app with some default clients, projects and nodeResrouces
  # to make sure every record is collected into the hierarchy
  default_client = Client.find_or_create(name: 'default',
                                         description: 'The default client')
  default_project = Project.find_or_create(name: 'default',
                                           client_id: default_client.id,
                                           description: 'The default project')
  NodeResource.find_or_create(project_id: default_project.id,
                              name: 'default')

  register Sinatra::MainRoutes
  register Sinatra::ClientRoutes
  register Sinatra::ProjectRoutes
  register Sinatra::NodeRoutes

  get '/report/?' do
    # get new client form
    @clients = Client.all
    erb :report
  end

  run!
end
