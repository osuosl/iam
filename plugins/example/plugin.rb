require 'sinatra/base'
require 'models'
require 'sequel'
require 'sqlite3'
require_relative '../base'

class ExamplePlugin < BasePlugin

  # Registers the plugin in the `Plugins` table with the following metadata:
  # - Name:              @name
  # - Measurement Table: @measurement
  # - Measurement Units: @measurement_units
  # - Resource Type:     @resource_type
  def register(measurement, measurement_units, resource_type)
    puts @name
    @measurement       = measurement
    puts @measurement
    @measurement_units = measurement_units
    puts @measurement_units
    @resource_type     = resource_type
    puts @resource_type
  end
end
