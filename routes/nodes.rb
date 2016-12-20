require 'sinatra/base'
require_relative '../logging/logs'
require_relative '../plugins/DiskSize/plugin'

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

      app.get '/node/:id/?' do
        # view a node
        @node = NodeResource[id: params[:id]]
        if @node.nil?
          MyLog.log.fatal 'routes/nodes: Node not found'
          halt 404, 'node not found'
        end
        @projects = Project.filter(id: @node.project_id).all
        erb :'nodes/show'
      end

      app.get '/node/:id/edit/?' do
        # get node edit form
        @node = NodeResource[id: params[:id]]
        if @node.nil?
          MyLog.log.fatal 'routes/nodes: Node not found [edit]'
          halt 404, 'node not found'
        end
        @projects = Project.all
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

      app.delete '/node/:id/?' do
        # delete a node
        node = NodeResource[id: params[:id]]
        node.delete unless node.nil?
        redirect '/nodes/?' unless node.nil?
        404
      end
    end
  end
  register NodeRoutes
end
