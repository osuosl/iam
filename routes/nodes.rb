require 'sinatra/base'

module Sinatra
  module NodeRoutes
    def self.registered(app)
      ##
      # Node Resource
      ##

      app.get '/node/new' do
        # get new node form
        erb :'nodes/edit'
      end

      app.get '/node/:id' do
        # view a node
        @node = NodeResource[id: params[:id]]
        halt 404, 'node not found' if @node.nil?
        erb :'nodes/show'
      end

      app.get '/node/:id/edit' do
        # get node edit form
        @node = NodeResource[id: params[:id]]
        halt 404, 'node not found' if @node.nil?
        erb :'nodes/edit'
      end

      app.get '/nodes' do
        # get a list of all node
        @nodes = NodeResource.all
        erb :'nodes/index'
      end

      # This could also be PUT
      app.post '/nodes' do
        # recieve new node
        node = NodeResource.create(project_id: Iam.settings.DB[:projects]
                                                .where(name: params[:project_name])
                                                .get(:id) || node.project_id,
                                   name:       params[:name],
                                   type:       params[:type] || '',
                                   cluster:    params[:cluster] || '',
                                   created:    DateTime.now || '',
                                   modified:   DateTime.now || '')
        redirect "/node/#{node.id}"
      end

      app.patch '/nodes' do
        # recieve an updated node
        node = NodeResource[id: params[:id]]

        node.update(project_id: Iam.settings.DB[:projects]
                                  .where(name: params[:project_name])
                                  .get(:id) || node.project_id,
                    name:       params[:name] || node.name,
                    type:       params[:type] || node.type,
                    cluster:    params[:cluster] || node.cluster,
                    created:    params[:created] || node.created,
                    modified:   params[:modified] || node.modified)
        redirect "/node/#{params[:id]}"
      end

      app.delete '/node/:id' do
        # delete a node
        @node = NodeResource[id: params[:id]]
        @node.delete unless @node.nil?
        redirect '/nodes' unless @node.nil?
        404
      end
    end
  end
  register NodeRoutes
end
