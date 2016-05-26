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

  # generate data
  (0...10).each do
    o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
    name = (0...10).map { o[rand(o.length)] }.join

    new_client = Client.create(name:  name,
                               contact_name:  'bob',
                               contact_email:  'bob@example.com',
                               description:  'blah')

    name = (0...10).map { o[rand(o.length)] }.join

    new_project = Project.create(name: name,
                                 client_id: 1 + rand(new_client.id),
                                 resources: 'node,thingy',
                                 description: 'blah')

    name = (0...10).map { o[rand(o.length)] }.join

    NodeResource.create(project_id: 1 + rand(new_client.id),
                        name: name,
                        type: 'ganeti',
                        cluster: 'cluster1.osuosl.org',
                        created: DateTime.now,
                        modified: DateTime.now)
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

  get '/demo' do
    @data = DiskSize.new.report
    @data = JSON.parse(@data)
    # puts @data
    puts 'get demo'
    erb :demo
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
    # @projects = Project[client_id: @client.id].all
    @projects = Project.filter(client_id: @client.id)
    puts @projects

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
    @clients = Client.all
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

  set :port, 4567
  set :bind, '0.0.0.0'
end

Iam.run!
