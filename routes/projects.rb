require 'sinatra/base'
require_relative '../logging/logs'

# IAM
module Sinatra
  # Projects routing
  module ProjectRoutes
    # rubocop:disable LineLength, MethodLength, AbcSize, CyclomaticComplexity, PerceivedComplexity
    def self.registered(app)
      ##
      # Projects
      ##

      app.get '/projects/new/?' do
        # get new project form
        @clients = Client.all
        erb :'projects/create'
      end

      app.get '/projects/?' do
        # get a list of all projects
        @projects = Project.all
        erb :'projects/index'
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

      app.get '/projects/:id/?' do
        # view a project
        @project = Project[id: params[:id]]
        if @project.nil?
          MyLog.log.fatal 'routes/projects: Project not found'
          halt 404, 'Project not found'
        end
        @client = Client.filter(id: @project.client_id).first

        if @client.nil?
          MyLog.log.fatal "routes/projects: Project's clients not found"
          halt 404, "Project's Client not found"
        end

        erb :'projects/show'
      end

      # This could also be PUT
      app.post '/projects/?' do
        # recieve new project
        project = Project.create(name: params[:name],
                                 client_id:   params[:client_id] || '',
                                 description: params[:description] || '')
        redirect "/projects/#{project.id}"
      end

      app.patch '/projects/?' do
        # set blanks to nil
        params[:name] = nil if params[:name] == ''
        params[:description] = nil if params[:description] == ''
        params[:active] = nil if params[:description] == ''

        # recieve an updated project
        project = Project[id: params[:id]]
        project.update(name:  params[:name] || project.name,
                       description: params[:description] || project.description,
                       active: params[:active] || project.active)

        # if project is set to inactive, disassociate this projects' resources
        # to the default project and delete this project
        unless project.active || project.name == 'default'
          resources = Report.get_resources(project)
          next if resources.empty?
          resources.each do |resource_type|
            resource_type.update(project_id: Project.find(name: 'default').id)
          end
          project.delete
          redirect '/projects' unless project.nil?
          404
        end
        redirect "/projects/#{params[:id]}"
      end
    end
  end
  register ProjectRoutes
end
