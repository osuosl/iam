require 'sinatra/base'
require_relative 'environment.rb'

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

  ##
  # Projects
  ##

  get '/projects/new' do
    # get new project form
    erb :'projects/edit'
  end

  get '/projects/:id' do
    # view a project
    @project = Project[id: params[:id]]
    halt 404, 'Project not found' if @project.nil?
    erb :'projects/show'
  end

  get '/projects/:id/edit' do
    # get project edit form
    @project = Project[id: params[:id]]
    halt 404, 'Project not found' if @project.nil?
    erb :'projects/edit'
  end

  get '/projects' do
    # get a list of all projects
    @projects = Project.each { |x| p x.name }
    erb :'projects/index'
  end

  # This could also be PUT
  post '/projects' do
    # recieve new project
    project = Project.create(name:        params[:name],
                             client_id:   Iam.settings.DB[:clients]
                                            .where(name: params[:client_name])
                                            .get(:id) || '',
                             resources:   params[:resources] || '',
                             description: params[:description] || '')
    redirect "/projects/#{project.id}"
  end

  patch '/projects' do
    # recieve an updated project
    project = Project[id: params[:id]]
    project.update(name:        params[:name] || project.name,
                   client_id:   Iam.settings.DB[:clients]
                                  .where(name: params[:client_name])
                                  .get(:id) || project.client_id,
                   resources:   params[:resources] || project.resources,
                   description: params[:description] || project.description)
    redirect "/projects/#{params[:id]}"
  end

  delete '/projects/:id' do
    # delete a project
    @project = Project[id: params[:id]]
    @project.delete unless @project.nil?
    redirect '/projects' unless @project.nil?
    404
  end

  ##
  # Node Resource
  ##

  get '/node/new' do
    # get new node form
    erb :'nodes/edit'
  end

  get '/node/:id' do
    # view a node
    @node = NodeResource[id: params[:id]]
    halt 404, 'node not found' if @node.nil?
    erb :'nodes/show'
  end

  get '/node/:id/edit' do
    # get node edit form
    @node = NodeResource[id: params[:id]]
    halt 404, 'node not found' if @node.nil?
    erb :'nodes/edit'
  end

  get '/nodes' do
    # get a list of all node
    @node = NodeResource.all
    erb :'nodes/index'
  end

  # This could also be PUT
  post '/nodes' do
    # recieve new node
    node = NodeResource.create(project_id: Iam.settings.DB[:projects]
                                            .where(name: params[:project_name])
                                            .get(:id) || node.project_id,
                               name:       params[:name],
                               type:       params[:type] || '',
                               cluster:    params[:cluster] || '',
                               created:    DateTime.now || '',
                               modified:   DateTime.now || '')
    redirect "/node/#{node.id}"
  end

  patch '/nodes' do
    # recieve an updated node
    node = NodeResource[id: params[:id]]

    node.update(project_id: Iam.settings.DB[:projects]
                              .where(name: params[:project_name])
                              .get(:id) || node.project_id,
                name:       params[:name] || node.name,
                type:       params[:type] || node.type,
                cluster:    params[:cluster] || node.cluster,
                created:    params[:created] || node.created,
                modified:   params[:modified] || node.modified)
    redirect "/node/#{params[:id]}"
  end

  delete '/node/:id' do
    # delete a node
    @node = NodeResource[id: params[:id]]
    @node.delete unless @node.nil?
    redirect '/nodes' unless @node.nil?
    404
  end
end
