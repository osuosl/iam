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
        puts "hihhiih"
        puts @project.client_id
        @clients = Client.filter(id: @project.client_id).all
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
        project = Project.create(name: params[:name],
                                 client_id:   Iam.settings.DB[:clients]
                                            .where(name: params[:client_name])
                                            .get(:id) || '',
                                 resources:   params[:resources] || '',
                                 description: params[:description] || ''
                                 )
        redirect "/projects/#{ project.id }"
      end

      app.patch '/projects/?' do
        # set blanks to nil
        params[:name] = nil if params[:name] == ''
        params[:resources] = nil if params[:resources] == ''
        params[:description] = nil if params[:description] == ''
        params[:active] = nil if params[:description] == ''

        # recieve an updated project
        project = Project[id: params[:id]]
        project.update(name:  params[:name] || project.name,
                       resources:   params[:resources] || project.resources,
                       description: params[:description] || project.description,
                       active: params[:active] || project.active)
        redirect "/projects/#{params[:id]}"
      end

      app.delete '/projects/:id/?' do
        # delete a project
        project = Project[id: params[:id]]
        project.delete unless project.nil?
        redirect '/projects' unless project.nil?
        404
      end
    end
  end
  register ProjectRoutes
end
