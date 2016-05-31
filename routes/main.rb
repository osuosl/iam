require 'sinatra/base'

module Sinatra
  module MainRoutes
    def self.registered(app)
      ##
      # Errors
      ##
      app.error 404 do
        'Not Found'
      end

      ##
      # static Pages
      ##
      app.get '/' do
        'Hello'
      end
    end
  end
  register MainRoutes
end
