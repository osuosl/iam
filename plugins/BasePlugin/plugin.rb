require 'sequel'
require_relative '../../environment.rb'
require_relative '../../models.rb'

SECONDS_IN_DAY = 60 * 60 * 24

class BasePlugin
  def initialize
    @redis = Redis.new(host: ENV['REDIS_HOST'])
    @database = Iam.settings.DB
    register
  end

  def register
    Plugin.find_or_create(name: @name, # create entry in Plugins table
                          resource_name: @resource_name,
                          storage_table: @table,
                          units: @units)
    # execute migration
    Sequel::Migrator.run(@database,
                         @current_dir + '/migrations',
                         column: @db_column)
  end
end
