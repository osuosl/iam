# frozen_string_literal: true
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

      app.get '/node/new/?:error?' do
        # get new node form
        @error = true if params[:error]
        @projects = Project.all
        @skus = Sku.all
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
        @project = Project.filter(id: @node.project_id).first
        node_sku = NodeResourcesProject.find(node_resource_id: params[:id])
        @sku = Sku.find(id: node_sku.sku_id)

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

        @data = Report.get_data(@project, @page, ENV['PER_PAGE'].to_i, 'node')

        erb :'nodes/summary'
      end

      app.get '/node/:id/edit/?' do
        # get node edit form
        @node = NodeResource[id: params[:id]]
        if @node.nil?
          MyLog.log.fatal 'routes/nodes: Node not found [edit]'
          halt 404, 'node not found'
        end
        @project = Project.filter(id: @node.project_id).first
        node_sku = NodeResourcesProject.find(node_resource_id: @node.id)
        @sku = Sku.find(id: node_sku.sku_id)

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
        if params[:name]
          begin
            node = NodeResource.create(project_id:  params[:project_id] || '',
                                       name:       params[:name],
                                       type:       params[:type] || '',
                                       cluster:    params[:cluster] || '',
                                       created:    DateTime.now || '',
                                       modified:   DateTime.now || '')
            NodeResourcesProject.create(project_id: node.project_id || '',
                                        node_resource_id: node.id || '',
                                        sku_id: params[:sku_id] || '')
          rescue StandardError
            redirect 'node/new/1'
          end
          redirect "/node/#{node.id}"
        end
      end

      app.patch '/nodes/?' do
        # set blanks to nil
        params[:name] = nil if params[:name] == ''
        params[:type] = nil if params[:type] == ''
        params[:cluster] = nil if params[:cluster] == ''
        params[:active] = nil if params[:active] == ''

        # recieve an updated node
        node = NodeResource[id: params[:id]]
        project_node = NodeResourcesProject.filter(node_resource_id: node.id).first

        node.update(project_id:  params[:project_id] || node.project_id,
                    name:       params[:name] || node.name,
                    type:       params[:type] || node.type,
                    cluster:    params[:cluster] || node.cluster,
                    modified:   DateTime.now || node.modified,
                    active: params[:active] || node.active)
        project_node.update(project_id: params[:project_id] || project_node.project_id,
                            node_resource_id: node.id || project_node.node_resource_id,
                            sku_id: params[:sku_id] || project_node.sku_id)
        redirect "/node/#{params[:id]}"
      end

      app.delete '/nodes/:id/?' do
        # delete a node
        node = NodeResource[id: params[:id]]
        # disassociate this nodes sku's and deactivate the node
        node.reassign_resources
        redirect '/nodes/?' unless node.nil?
        404
      end
    end
  end
  register NodeRoutes
end
