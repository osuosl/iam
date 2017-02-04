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

      app.get '/projects/:id/?' do
        # view a project
        @project = Project[id: params[:id]]
        if @project.nil?
          MyLog.log.fatal 'routes/projects: Project not found'
          halt 404, 'Project not found'
        end
        @clients = Client.filter(id: @project.client_id).all
        if @clients.nil?
          MyLog.log.fatal "routes/projects: Project's clients not found"
          halt 404, "Project's Client not found"
        end

        @nodes = @project.node_resources

        page_size = 10
        record_count = Iam.settings.DB[:node_resources].count
        total_pages = (record_count / page_size.to_f).ceil

        (1..total_pages).each do |page_no|

        page_count = (record_count / page_size.to_f).ceil
        page_count = 1 if page_count == 0

        limit(page_size, (page_no - 1) * page_size).
          with_extend(Dataset::Pagination).
          clone(:page_size=>page_size, :current_page=>page_no, :pagination_record_count=>record_count, :page_count=>page_count)
        end


        @dbs = @project.db_resources


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
