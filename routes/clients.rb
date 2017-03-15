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
      app.get '/clients/new/?:error?' do
        # get new client form

        @error = 'That client already exists' if params[:error]
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

        unless @projects.nil?
          @client_data = {}
          @projects.each do |project|
            data = Report.project_data(project)
            (@client_data[project.name] ||= []) << data
          end
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

      app.get '/clients/:id/billing/?:date_selection?' do
        @client = Client[id: params[:id]]

        @projects = @client.projects

        unless @projects.nil?
          @client_data = {}
          @projects.each do |project|
            data = Report.project_data(project)
            (@client_data[project.name] ||= []) << data
          end
        end

        @date_selection = params[:date_selection]

        @data = Report.sum_data(@client_data, @date_selection)
        erb :'clients/billing'
      end

      app.get '/clients/?' do
        # get a list of all clients
        @clients = Client.all
        erb :'clients/index'
      end

      # This could also be PUT
      app.post '/clients/?' do
        # recieve new client if it is valid
        if params[:name]
          begin
            client = Client.create(name: params[:name],
                                   description: params[:description] || '',
                                   contact_email: params[:contact_name] || '',
                                   contact_name: params[:contact_email] || '')
          rescue StandardError
            @err = 1
            redirect "/clients/new/#{@err}"
          end
          redirect "/clients/#{client.id}"
        end
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
