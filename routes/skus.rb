# frozen_string_literal: true
require 'sinatra/base'
require_relative '../logging/logs'

# Our app
module Sinatra
  # Our sku Routing
  module SkuRoutes
    # rubocop:disable LineLength, MethodLength, AbcSize, CyclomaticComplexity, PerceivedComplexity
    def self.registered(app)
      ##
      # SKUs Resource
      ##

      app.get '/skus/new/?:error?' do
        # get new sku form
        @error = true if params[:error]
        erb :'skus/create'
      end

      app.get '/skus/:id/?' do
        # view a sku
        @sku = Sku[id: params[:id]]
        if @sku.nil?
          MyLog.log.fatal 'routes/sku: sku not found'
          halt 404, 'sku resource not found'
        end
        erb :'skus/show'
      end

      app.get '/skus/:id/edit/?' do
        # get sku edit form
        @sku = Sku[id: params[:id]]
        if @sku.nil?
          MyLog.log.fatal 'routes/sku: sku not found [edit]'
          halt 404, 'sku not found'
        end
        erb :'skus/edit'
      end

      app.get '/skus/?' do
        # get a list of all skus
        @skus = Sku.all
        erb :'skus/index'
      end

      # This could also be PUT
      app.post '/skus/?' do
        # recieve new sku
        if params[:name]
          begin
            sku = Sku.create(name:         params[:name],
                             description:  params[:description] || '',
                             family:       params[:family] || '',
                             rate:         params[:rate] || '',
                             sku_num:      params[:sku_num] || '')
          rescue StandardError
            redirect '/skus/new/1'
          end
          redirect "/skus/#{sku.id}"
        end
      end

      app.patch '/skus/?' do
        # set blanks to nil
        begin
          params[:name] = nil if params[:name] == ''
          params[:description] = nil if params[:description] == ''
          params[:family] = nil if params[:family] == ''
          params[:rate] = nil if params[:rate] == ''
          params[:sku_num] = nil if params[:sku_num] == ''
          params[:active] = nil if params[:active] == ''

          # recieve an updated sku
          sku = Sku[id: params[:id]]
          sku.update(name:              params[:name] || sku.name,
                     description:       params[:description] || sku.description,
                     sku_num:           params[:sku_num] || sku.sku_num,
                     family:            params[:family] || sku.family,
                     rate:              params[:rate] || sku.rate,
                     active:            params[:active] || sku.active)
          redirect "/skus/#{params[:id]}"
        end
      end

      app.delete '/skus/:id/?' do
        # delete a sku
        sku = Sku[id: params[:id]]
        sku.reassign_resources unless sku.name == 'default'
        redirect '/skus/?' unless sku.nil?
        404
      end
    end
  end
  register SkuRoutes
end
