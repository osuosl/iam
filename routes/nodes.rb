require 'sinatra/base'
require_relative '../logging/logs'

# Our app
module Sinatra
  # Our Node Routing
  module NodeRoutes
    # rubocop:disable LineLength, MethodLength, AbcSize, CyclomaticComplexity, PerceivedComplexity
    def self.registered(app)
      ##
      # Node Resource
      ##

      app.get '/node/new/?' do
        # get new node form
        @projects = Project.all
        erb :'nodes/create'
      end

      # rubocop:disable BracesAroundHashParameters
      app.get '/node/:id/?' do
        # view a node
        @node = NodeResource[id: params[:id]]
        if @node.nil?
          MyLog.log.fatal 'routes/nodes: Node not found'
          halt 404, 'node not found'
        end
        # get data from plugins
        @projects = Project.filter(id: @node.project_id).first

        # get data from plugins
        @vcpu_data = VCPUCount.new.report({ node: @node.name })
        @ramsize_data = RamSize.new.report({ node: @node.name })
        @disksize_data = DiskSize.new.report({ node: @node.name })
        @disktemplate_data = DiskTemplate.new.report({ node: @node.name })

        # find most recent time and store into @update_time
        @updated = Time.new(0)
        if @vcpu_data.last
          if @vcpu_data.last[:created] > @updated
            @update_time = @vcpu_data.last[:created]
          end
        end
        if @ramsize_data.last
          if @ramsize_data.last[:created] > @updated
            @update_time = @ramsize_data.last[:created]
          end
        end
        if @disksize_data.last
          if @disksize_data.last[:created] > @updated
            @update_time = @disksize_data.last[:created]
          end
        end
        if @disktemplate_data.last
          if @disktemplate_data.last[:created] > @updated
            @update_time = @disktemplate_data.last[:created]
          end
        end
        erb :'nodes/show'
      end
      # rubocop:enable BlockLength

      app.get '/node/summary/:id/?:page?' do
        # view list of node resources and their measurements
        @project = Project.filter(id: params[:id]).first
        @nodes = NodeResource[project_id: params[:id]]

        # current page
        @page = params[:page].to_f
        @page = 1 if @page.zero?

        # The number of resources displayed on a page
        @per_page = 10

        @data = Report.get_data(@project, @page, @per_page, 'node')

        erb :'nodes/summary'
      end

      app.get '/node/:id/edit/?' do
        # get node edit form
        @node = NodeResource[id: params[:id]]
        if @node.nil?
          MyLog.log.fatal 'routes/nodes: Node not found [edit]'
          halt 404, 'node not found'
        end
        @projects = Project.all
        @project = @projects.find(@node.project_id).first
        erb :'nodes/edit'
      end

      app.get '/nodes/?' do
        # get a list of all node
        @nodes = NodeResource.all
        erb :'nodes/index'
      end

      # This could also be PUT
      app.post '/nodes/?' do
        # recieve new node
        node = NodeResource.create(project_id:  params[:project_id] || '',
                                   name:       params[:name],
                                   type:       params[:type] || '',
                                   cluster:    params[:cluster] || '',
                                   created:    DateTime.now || '',
                                   modified:   DateTime.now || '')
        redirect "/node/#{node.id}"
      end

      app.patch '/nodes/?' do
        # set blanks to nil
        params[:name] = nil if params[:name] == ''
        params[:type] = nil if params[:type] == ''
        params[:cluster] = nil if params[:cluster] == ''
        params[:active] = nil if params[:description] == ''

        # recieve an updated node
        node = NodeResource[id: params[:id]]

        node.update(project_id:  params[:project_id] || node.project_id,
                    name:       params[:name] || node.name,
                    type:       params[:type] || node.type,
                    cluster:    params[:cluster] || node.cluster,
                    modified:   DateTime.now || node.modified,
                    active: params[:active] || node.active)

        redirect "/node/#{params[:id]}"
      end
    end
  end
  register NodeRoutes
end
