# frozen_string_literal: true
require 'sinatra/base'
require_relative '../logging/logs'

# Our app
module Sinatra
  # Our Database Routing
  module DbRoutes
    # rubocop:disable LineLength, MethodLength, AbcSize, CyclomaticComplexity, PerceivedComplexity
    def self.registered(app)
      ##
      # Database Resource
      ##

      app.get '/db/new/?:error?' do
        # get new database form
        @error = true if params[:error]
        @projects = Project.all
        erb :'database/create'
      end

      app.get '/db/:id/?' do
        # view a database
        @db = DbResource[id: params[:id]]
        if @db.nil?
          MyLog.log.fatal 'routes/database: Database Resource not found'
          halt 404, 'database resource not found'
        end

        # get data from plugins
        @projects = Project.filter(id: @db.project_id).first
        @db_size = DBSize.new.report(db: @db.name)

        # find most recent time and store into @update_time
        @updated = Time.new(0)
        if @db_size.last
          if @db_size.last[:created] > @updated
            @update_time = @db_size.last[:created]
          end
        end
        erb :'database/show'
      end

      app.get '/db/summary/:id/?:page?' do
        # view list of db resources and their measurements
        @project = Project.filter(id: params[:id]).first
        @dbs = DbResource[project_id: params[:id]]

        # current page
        @page = params[:page].to_f
        @page = 1 if @page.zero?

        # The number of resources displayed on a page
        @per_page = 10

        @data = Report.get_data(@project, @page, @per_page, 'db')

        erb :'database/summary'
      end

      app.get '/db/:id/edit/?' do
        # get database edit form
        @db = DbResource[id: params[:id]]
        if @db.nil?
          MyLog.log.fatal 'routes/database: Database Resource not found [edit]'
          halt 404, 'database resource not found'
        end

        # get data from plugins
        @projects = Project.all
        @project = @projects.find(@db.project_id).first
        erb :'database/edit'
      end

      app.get '/dbs/?' do
        # get a list of all database
        @dbs = DbResource.all
        erb :'database/index'
      end

      # This could also be PUT
      app.post '/dbs/?' do
        # recieve new database
        if params[:name]
          begin
            db = DbResource.create(project_id:  params[:project_id] || '',
                                   name:       params[:name],
                                   type:       params[:type] || '',
                                   server:    params[:server] || '',
                                   created:    DateTime.now || '',
                                   modified:   DateTime.now || '')
          rescue StandardError
            @err = 1
            redirect "/db/new/#{@err}"
          end
        redirect "/db/#{db.id}"
        end
      end

      app.patch '/dbs/?' do
        # set blanks to nil
        params[:name] = nil if params[:name] == ''
        params[:type] = nil if params[:type] == ''
        params[:server] = nil if params[:server] == ''
        params[:active] = nil if params[:description] == ''

        # recieve an updated database
        db = DbResource[id: params[:id]]

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
        db = DbResource[id: params[:id]]
        db.delete unless db.nil?
        redirect '/dbs/?' unless db.nil?
        404
      end
    end
  end
  register DbRoutes
end
