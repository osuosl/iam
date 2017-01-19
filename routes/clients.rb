require 'sinatra/base'
require_relative '../logging/logs'

# IAM
module Sinatra
  # Client routing
  module ClientRoutes
    # rubocop:disable LineLength, MethodLength, AbcSize, CyclomaticComplexity, PerceivedComplexity
    def self.registered(app)
      ##
      # Clients
      ##
      app.get '/clients/new/?' do
        # get new client form
        erb :'clients/create'
      end

      app.get '/clients/:id/?' do
        # view a client
        @client = Client[id: params[:id]]

        if @client.nil?
          MyLog.log.fatal 'routes/clients: Client not found'
          halt 404, 'Client not found'
        end

        @projects = @client.projects

        matrix = {}
        # query the plugins model to determine what measurements are available
        plugins = Plugin.all
        # make a matrix of resource types and their plugins
        # { 'node': ['DiskSize', 'VCPU', ...]
        #   'db': ['Size', ...]
        #   ...}
        plugins.each do |plugin|
          (matrix[plugin.resource_name] ||= []) << plugin.name
        end

        @client_data = {}
        resource_data = {}

        matrix.each do |resource_type, measurements|
          # for each resource type in the matrix, get a list of all that type
          # of resource each project has
          @projects.each do |project|
            resources = project.send(resource_type + '_resources')
            # for each of those resources, get all the measuremnts for that
            # type of resource. Put it all in a big hash.
            resources.each do |resource|
              resource_data[resource.name] ||= {}
              measurements.each do |measurement|
                data = Object.const_get(measurement).new.report({node: resource.name})
                if !data[0].nil?
                  if data[0][:value].is_a? Numeric
                    data_average = DataUtil.average_value(data)
                  else
                    data_average = data[-1][:value]
                  end
                  resource_data[resource.name].merge!(measurement => data_average)
                end
              end
            end
          end
          (@client_data[resource_type] ||= []) << resource_data
        end

        erb :'clients/show'
      end

      app.get '/clients/:id/edit/?' do
        # get client edit form
        @client = Client[id: params[:id]]
        if @client.nil?
          MyLog.log.fatal 'routes/clients: Client not found [edit]'
          halt 404, 'routes/clients: Client not found'
        end
        erb :'clients/edit'
      end

      app.get '/clients/?' do
        # get a list of all clients
        @clients = Client.all
        erb :'clients/index'
      end

      # This could also be PUT
      app.post '/clients/?' do
        # recieve new client
        if params[:name]
          client = Client.create(name: params[:name],
                                 description: params[:description] || '',
                                 contact_email: params[:contact_name] || '',
                                 contact_name: params[:contact_email] || '')
        end
        redirect "/clients/#{client.id}"
      end

      app.patch '/clients/?' do
        # set blanks to nil
        params[:name] = nil if params[:name] == ''
        params[:contact_name] = nil if params[:contact_name] == ''
        params[:contact_email] = nil if params[:contact_email] == ''
        params[:description] = nil if params[:description] == ''
        params[:active] = nil if params[:description] == ''

        # recieve an updated client
        client = Client[id: params[:id]]
        client.update(name: params[:name] || client.name,
                      description: params[:description] || client.description,
                      contact_email: params[:contact_email] || client.contact_email,
                      contact_name: params[:contact_name] || client.contact_name,
                      active: params[:active] || client.active)
        redirect "/clients/#{params[:id]}"
      end

      app.delete '/clients/:id/?' do
        # delete a client
        client = Client[id: params[:id]]
        client.delete unless client.nil?
        redirect '/clients' unless client.nil?
        404
      end
    end
  end
  register ClientRoutes
end
