require 'sinatra/base'
require_relative '../logging/logs'

# Our app
module Sinatra
  # this is our routes for the main app and non-related to models
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
    end
  end
  register MainRoutes
end
