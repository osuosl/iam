require 'sinatra/base'

module Sinatra
  module ProjectRoutes
    def self.registered(app)
      ##
      # Projects
      ##

      app.get '/projects/new' do
        # get new project form
        erb :'projects/edit'
      end

      app.get '/projects/:id' do
        # view a project
        @project = Project[id: params[:id]]
        halt 404, 'Project not found' if @project.nil?
        erb :'projects/show'
      end

      app.get '/projects/:id/edit' do
        # get project edit form
        @project = Project[id: params[:id]]
        halt 404, 'Project not found' if @project.nil?
        erb :'projects/edit'
      end

      app.get '/projects' do
        # get a list of all projects
        @projects = Project.each { |x| p x.name }
        erb :'projects/index'
      end

      # This could also be PUT
      app.post '/projects' do
        # recieve new project
        project = Project.create(name:        params[:name],
               client_id:   Iam.settings.DB[:clients]
                  .where(name: params[:client_name])
                  .get(:id) || '',
               resources:   params[:resources] || '',
               description: params[:description] || '')
        redirect "/projects/#{project.id}"
      end

      app.patch '/projects' do
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

      app.delete '/projects/:id' do
        # delete a project
        @project = Project[id: params[:id]]
        @project.delete unless @project.nil?
        redirect '/projects' unless @project.nil?
        404
      end
    end
  end
  register ProjectRoutes
end
