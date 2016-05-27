require 'sinatra/base'
require File.expand_path '../environment.rb', __FILE__

# IAM - a resource usage metric collection and reporting system
class Iam < Sinatra::Base
  set :show_exceptions, :after_handler
  # require the models, but make sure to do it after the test db is migrated
  require 'models'

  # load up all the plugins
  plugin_dirs = File.dirname(__FILE__) + '/plugins/**/'

  Rake::FileList[plugin_dirs + 'plugin.rb'].each do |file|
    require file
  end

  ##
  # Errors
  ##
  error 404 do
    'Not Found'
  end

  ##
  # static Pages
  ##

  get '/' do
    'Hello'
  end

  ##
  # Clients
  ##

  get '/clients/new' do
    # get new client form
    erb :'clients/edit'
  end

  get '/clients/:id' do
    # view a client
    @client = Client[id: params[:id]]
    halt 404, 'Client not found' if @client.nil?
    erb :'clients/show'
  end

  get '/clients/:id/edit' do
    # get client edit form
    @client = Client[id: params[:id]]
    halt 404, 'Client not found' if @client.nil?
    erb :'clients/edit'
  end

  get '/clients' do
    # get a list of all clients
    @clients = Client.each { |x| p x.name }
    erb :'clients/index'
  end

  # This could also be PUT
  post '/clients' do
    # recieve new client
    client = Client.create(name: params[:name],
                           description: params[:description] || '',
                           contact_email: params[:contact_name] || '',
                           contact_name: params[:contact_email] || '')
    redirect "/clients/#{client.id}"
  end

  patch '/clients' do
    # recieve an updated client
    client = Client[id: params[:id]]

    client.update(name: params[:name] || client.name,
                  description: params[:description] || client.description,
                  contact_email: params[:contact_name] || client.contact_name,
                  contact_name: params[:contact_email] || client.contact_email)
    redirect "/clients/#{params[:id]}"
  end

  delete '/clients/:id' do
    # delete a client
    @client = Client[id: params[:id]]
    @client.delete unless @client.nil?
    redirect '/clients' unless @client.nil?
    404
  end

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
    erb :'node/edit'
  end

  get '/node/:id' do
    # view a node
    @node = NodeResource[id: params[:id]]
    halt 404, 'node not found' if @node.nil?
    erb :'node/show'
  end

  get '/node/:id/edit' do
    # get node edit form
    @node = NodeResource[id: params[:id]]
    halt 404, 'node not found' if @node.nil?
    erb :'node/edit'
  end

  get '/nodes' do
    # get a list of all node
    @node = NodeResource.all
    erb :'clients/index'
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
