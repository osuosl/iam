require 'sequel'
require 'logging'
require_relative '../../environment.rb'
require_relative '../../models.rb'
require_relative '../util.rb'
require_relative '../../logging/logs'

# This is the base plugin for all other plugins.
# this creates the baseline for database interaction such as tables registration
# and reporting,
class BasePlugin
  SECONDS_IN_DAY = 60 * 60 * 24

  # rubocop:disable ParameterLists
  def initialize(name, resource, units, table, column, mig_dir)
    @node_cache = Cache.new(Iam.settings.node_cache_file)
    @db_cache = Cache.new(Iam.settings.db_cache_file)
    @database = Iam.settings.DB
    @name = name
    @resource_name = resource
    @units = units
    @table = table
    @db_column = column
    @migrations_dir = mig_dir
  end

  def register
    Plugin.find_or_create(name: @name, # create entry in Plugins table
                          resource_name: @resource_name,
                          storage_table: @table.to_s,
                          units: @units)
    # execute migration
    Sequel::Migrator.run(@database,
                         @migrations_dir,
                         column: @db_column)
  end

  # General report function
  # Returns Ruby Hash of report data
  # rubocop:disable Metrics/LineLength
  # rubocop:disable MethodLength, Metrics/AbcSize, CyclomaticComplexity, Metrics/PerceivedComplexity
  def report(resource = { node: '*' },
             start_time = Time.now - (30 * SECONDS_IN_DAY),
             end_time = Time.now)
    MyLog.log.error StandardError.new(
      'BasePlugin: start_time and end_time should be Time objects'
    ) unless end_time.is_a?(Time) && start_time.is_a?(Time)
    raise TypeError, 'start_time and end_time should be Time objects'\
      unless end_time.is_a?(Time) && start_time.is_a?(Time)

    MyLog.log.error StandardError.new(
      'BasePlugin: start_time > end_time'
    ) unless start_time < end_time
    raise ArgumentError, 'start_time > end_time'\
      unless start_time < end_time

    # if fqdn is default, return all
    if resource == { node: '*' }
      dataset = @database[@table].where(created: start_time..end_time)
    # else return data filtered with fqdn name
    else
      dataset = @database[@table].where(resource)
                                 .where(created: start_time..end_time)
    end
    # Reports in a ruby hash
    dataset.all
  end
end

# our base level testing initialization
class TestingPlugin < BasePlugin
  #  super()
  def initialize
    name = 'TestingPlugin'
    resource_name = 'resource'
    units = 'units'
    table = :test_plugin_measurements
    db_column = :test_plugin_ver
    migrations_dir = File.dirname(__FILE__) + '/migrations'
    super(name, resource_name, units, table, db_column, migrations_dir)
    register
  end
end
