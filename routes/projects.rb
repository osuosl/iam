require 'sinatra/base'
require_relative '../logging/logs'
module Sinatra
  module ProjectRoutes
    def self.registered(app)
      ##
      # Projects
      ##

      app.get '/projects/new/?' do
        # get new project form
        erb :'projects/create'
      end

      app.get '/projects/:id/?' do
        # view a project
        @project = Project[id: params[:id]]
        if @project.nil?
          MyLog.log.fatal 'routes/projects: Project not found'
          halt 404, 'Project not found'
        end
        erb :'projects/show'
      end

      app.get '/projects/:id/edit/?' do
        # get project edit form
        @project = Project[id: params[:id]]
        if @project.nil?
          MyLog.log.fatal 'routes/projects: Project not found [edit]'
          halt 404, 'Project not found'
        end
        erb :'projects/edit'
      end

      app.get '/projects/?' do
        # get a list of all projects
        @projects = Project.all
        erb :'projects/index'
      end

      # This could also be PUT
      app.post '/projects/?' do
        # recieve new project
        project = Project.create(name:        params[:name],
               client_id:   Iam.settings.DB[:clients]
                  .where(name: params[:client_name])
                  .get(:id) || '',
               resources:   params[:resources] || '',
               description: params[:description] || '')
        redirect "/projects/#{project.id}"
      end

      app.patch '/projects/?' do
        # recieve an updated project
        project = Project[id: params[:id]]
        project.update(name:        params[:name] || project.name,
           client_id:   Iam.settings.DB[:clients]
              .where(name: params[:client_name])
               .get(:id), #|| project.client_id,
           resources:   params[:resources] || project.resources,
           description: params[:description] || project.description,
           active: params[:active] || project.active)
        redirect "/projects/#{params[:id]}"
      end
    end
  end
  register ProjectRoutes
end
