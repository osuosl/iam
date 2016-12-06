require 'sinatra/base'
require_relative '../logging/logs'

# Our app
module Sinatra
  # Our D Routing
  module DBResource
    # rubocop:disable LineLength, MethodLength, AbcSize, CyclomaticComplexity, PerceivedComplexity
    def self.registered(app)
      ##
      # Database Resource
      ##

      app.get '/db/new/?' do
        # get new database form
        @db = DB.all
        erb :'database/create'
      end

      app.get '/db/:id/?' do
        # view a database
        @db = DBResource[id: params[:id]]
        if @db.nil?
          MyLog.log.fatal 'routes/database: Database not found'
          halt 404, 'database not found'
        end
        @projects = Project.filter(id: @db.project_id).all
        erb :'database/show'
      end

      app.get '/db/:id/edit/?' do
        # get database edit form
        @db = DBResource[id: params[:id]]
        if @db.nil?
          MyLog.log.fatal 'routes/database: Database not found [edit]'
          halt 404, 'database not found'
        end
        @projects = Project.all
        erb :'database/edit'
      end

      app.get '/dbs/?' do
        # get a list of all database
        @db = DBResource.all
        erb :'database/index'
      end

      # This could also be PUT
      app.post '/dbs/?' do
        # recieve new database
        db = DBResource.create(project_id:  params[:project_id] || '',
                                   name:       params[:name],
                                   type:       params[:type] || '',
                                   server:    params[:server] || '',
                                   created:    DateTime.now || '',
                                   modified:   DateTime.now || '')
        redirect "/db/#{db.id}"
      end

      app.patch '/dbs/?' do
        # set blanks to nil
        params[:name] = nil if params[:name] == ''
        params[:type] = nil if params[:type] == ''
        params[:server] = nil if params[:server] == ''
        params[:active] = nil if params[:description] == ''

        # recieve an updated database
        db = DBResource[id: params[:id]]

        db.update(project_id:  params[:project_id] || db.project_id,
                    name:       params[:name] || db.name,
                    type:       params[:type] || db.type,
                    server:    params[:server] || db.server,
                    modified:   DateTime.now || db.modified,
                    active: params[:active] || db.active)
        redirect "/db/#{params[:id]}"
      end

      app.delete '/db/:id/?' do
        # delete a database
        db = DBResource[id: params[:id]]
        db.delete unless db.nil?
        redirect '/dbs/?' unless db.nil?
        404
      end
    end
  end
  register DBRoutes
end
