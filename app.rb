# frozen_string_literal: true
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

  # load the cache_control protocol for each page on IAM
  before do
    cache_control :public, :must_revalidate, max_age: Iam.settings.cache_max_age
  end

  # initialize the app with some default clients, projects and nodeResources
  # to make sure every record is collected into the hierarchy
  default_client = Client.find_or_create(name: 'default',
                                         description: 'The default client')
  default_project = Project.find_or_create(name: 'default',
                                           client_id: default_client.id,
                                           description: 'The default project')
  default_sku = Sku.find_or_create(name: 'default',
                                   description: 'The default SKU')
  NodeResourcesProject.find_or_create(project_id: default_project.id,
                                      sku_id: default_sku.id)
  DbResourcesProject.find_or_create(project_id: default_project.id,
                                    sku_id: default_sku.id)

  register Sinatra::MainRoutes
  register Sinatra::ClientRoutes
  register Sinatra::ProjectRoutes
  register Sinatra::NodeRoutes
  register Sinatra::DbRoutes
  register Sinatra::SkuRoutes
end
