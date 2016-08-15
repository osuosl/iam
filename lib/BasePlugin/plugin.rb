require 'sequel'
require 'logging'
require_relative '../../environment.rb'
require_relative '../../models.rb'
require_relative '../util.rb'

class BasePlugin
  SECONDS_IN_DAY = 60 * 60 * 24
  @@cache = Cache.new(ENV['CACHE_FILE'])
  @@database = Iam.settings.DB

  @@name = nil
  @@resource_name = nil
  @@units = nil
  @@table = nil
  @@db_column = nil
  @@migrations_dir = nil

  def register
    Plugin.find_or_create(name: @@name, # create entry in Plugins table
                          resource_name: @@resource_name,
                          storage_table: @table.to_s,
                          units: @@units)
    # execute migration
    Sequel::Migrator.run(@@database,
                         @@migrations_dir,
                         column: @@db_column)
  end

  # General report function
  # Returns Ruby Hash of report data
  def report(resource = {node: '*'}, start_time = Time.now - (30 * SECONDS_IN_DAY),
             end_time = Time.now)
    log.error StandardError.new(
      "start_time and end_time should be Time objects"
    )unless end_time.is_a? Time and start_time.is_a? Time
    raise TypeError.new("start_time and end_time should be Time objects")\
      unless end_time.is_a? Time and start_time.is_a? Time

    log.error StandardError.new(
      "start_time > end_time"
    )unless start_time < end_time
    raise ArgumentError.new("start_time > end_time")\
      unless start_time < end_time

    # if fqdn is default, return all
    if resource == {node: '*'}
      dataset = @@database[@@table].where(created: start_time..end_time)
    # else return data filtered with fqdn name
    else
      dataset = @@database[@@table].where(resource)
                                   .where(created: start_time..end_time)
    end
    # Reports in a ruby hash
    dataset.all
  end
end

class TestingPlugin < BasePlugin
  def initialize
    @@name = 'TestingPlugin'
    @@resource_name = 'resource'
    @@units = 'units'
    @@table = :test_plugin_measurements
    @@db_column = :test_plugin_ver
    @@migrations_dir= File.dirname(__FILE__) + '/migrations'
    register
  end
end
