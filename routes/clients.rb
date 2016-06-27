require 'sinatra/base'

module Sinatra
  module ClientRoutes
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
        halt 404, 'Client not found' if @client.nil?
        @projects = Project.filter(client_id: @client.id)
        erb :'clients/show'
      end

      app.get '/clients/:id/edit/?' do
        # get client edit form
        @client = Client[id: params[:id]]
        halt 404, 'Client not found' if @client.nil?
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

        # recieve an updated client
        client = Client[id: params[:id]]
        client.update(name: params[:name] || client.name,
                      description: params[:description] || client.description,
                      contact_email: params[:contact_email] || client.contact_email,
                      contact_name: params[:contact_name] || client.contact_name)
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
