# frozen_string_literal: true
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

      app.get '/projects/new/?:error?' do
        # get new project form
        @error = true if params[:error]
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

        @project_data = {}
        Report.plugin_matrix.each do |res_type, _resource_meas|
          @project_data ||= {}
          @project_data[res_type] = @project.send("#{res_type}_resources")
        end

        @exclude_keys = [:id, :project_id, :created, :modified, :active,
                         :db_project_id, :node_project_id]

        erb :'projects/show'
      end

      # This could also be PUT
      app.post '/projects/?' do
        # recieve new project
        if params[:name]
          begin
            project = Project.create(name: params[:name],
                                     client_id:   params[:client_id] || '',
                                     description: params[:description] || '')
          rescue StandardError
            redirect '/projects/new/1'
          end
          redirect "/projects/#{project.id}"
        end
      end

      app.patch '/projects/?' do
        # set blanks to nil
        params[:name] = nil if params[:name] == ''
        params[:description] = nil if params[:description] == ''
        params[:active] = nil if params[:active] == ''

        # recieve an updated project
        project = Project[id: params[:id]]
        project.update(name: params[:name] || project.name,
                       description: params[:description] || project.description,
                       active: params[:active] || project.active)
        redirect "/projects/#{params[:id]}"
      end

      app.delete '/projects/:id/?' do
        # delete a project
        project = Project[id: params[:id]]
        # disassociate this projects' resources to the default project and
        # delete this project
        project.reassign_resources unless project.name == 'default'
        redirect '/projects' unless project.nil?
        404
      end
    end
  end
  register ProjectRoutes
end
