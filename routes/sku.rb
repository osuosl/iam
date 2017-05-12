# frozen_string_literal: true
require 'sinatra/base'
require_relative '../logging/logs'

# Our app
module Sinatra
  # Our SKU Routing
  module SkuRoutes
    # rubocop:disable LineLength, MethodLength, AbcSize, CyclomaticComplexity, PerceivedComplexity
    def self.registered(app)
      ##
      # SKU Resource
      ##

      app.get '/skus/?' do
        # view a list of all skus
        @skus = Sku.all
        erb :'skus/index'
      end
    end
  end
end
