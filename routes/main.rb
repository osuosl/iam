require 'sinatra/base'
require_relative '../logging/logs'

# Our app
module Sinatra
  # this is our routes for the main app and non-related to models
  # rubocop:disable MethodLength
  module MainRoutes
    def self.registered(app)
      ##
      # Errors
      ##
      app.error 404 do
        MyLog.log.fatal 'routes/main: Not found'
        'Not Found'
      end

      ##
      # static Pages
      ##
      app.get '/' do
        erb :index
      end
      app.get '/report/?' do
        # get new client form
        @clients = Client.all
        erb :report
      end
    end
  end
  register MainRoutes
end
