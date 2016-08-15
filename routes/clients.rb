require 'sinatra/base'
module Sinatra
  module ClientRoutes
    def self.registered(app)
      ##
      # Clients
      ##
      app.get '/clients/new/?' do
        # get new client form
        erb :'clients/edit'
      end

      app.get '/clients/:id/?' do
        # view a client
        @client = Client[id: params[:id]]
        if @client.nil?
          log.fatal 'Client not found'
          halt 404, 'Client not found'
        end
        erb :'clients/show'
      end

      app.get '/clients/:id/edit/?' do
        # get client edit form
        @client = Client[id: params[:id]]
        if @client.nil?
          log.fatal 'Client not found'
          halt 404, 'Client not found'
        end
        erb :'clients/edit'
      end

      app.get '/clients/?' do
        # get a list of all clients
        @clients = Client.each { |x| p x.name }
        erb :'clients/index'
      end

      # This could also be PUT
      app.post '/clients/?' do
        # recieve new client
        client = Client.create(name: params[:name],
                               description: params[:description] || '',
                               contact_email: params[:contact_name] || '',
                               contact_name: params[:contact_email] || '')
        redirect "/clients/#{client.id}"
      end

      app.patch '/clients/?' do
        # recieve an updated client
        client = Client[id: params[:id]]

        client.update(name: params[:name] || client.name,
                      description: params[:description] || client.description,
                      contact_email: params[:contact_name] || client.contact_name,
                      contact_name: params[:contact_email] || client.contact_email)
        redirect "/clients/#{params[:id]}"
      end

      app.delete '/clients/:id/?' do
        # delete a client
        @client = Client[id: params[:id]]
        @client.delete unless @client.nil?
        redirect '/clients' unless @client.nil?
        404
      end
    end
  end
  register ClientRoutes
end
