require 'logging'
require 'sequel'
require_relative '../../lib/BasePlugin/plugin.rb'
require_relative '../../environment.rb'
require_relative '../../models.rb'
require_relative '../../logging/logs'

# DBSizes data plugin
class DBSize < BasePlugin
  def initialize
    name = 'DBSize'
    resource_name = 'db'
    units = 'bytes'
    table = :db_size_measurements
    db_column = :db_size_ver
    migrations_dir = File.dirname(__FILE__) + '/migrations'

    super(name, resource_name, units, table, db_column, migrations_dir)
    register
  end

  # rubocop: disable MethodLength, AbcSize
  def store(db_host)
    # Pull node information from cache as a ruby hash
    db_info = @cache.get(db_host)

    # Check for valid data
    if db_info['db_size'].nil? || db_info == ''
      MyLog.log.warn "DBSize: No DBSize information for #{db_host}"
      raise "No DBSize information for #{db_host}\n"
    elsif !db_info['db_size'].is_a? Numeric
      MyLog.log.warn "DBSize: DB information for #{db_host} \
        malformed (should be a number)"
      raise "DB information for #{db_host} malformed (should be a number)\n"
    end

    # check if resource exists, otherwise create it for the default project
    db_resource = @database[:db_resources].where(name: db_host).get(:id)

    db_resource = default_db(db_host, db_info['type'],
                             db_info['server']) unless db_resource

    # Insert data into db_size_measurements table
    @database[@table].insert(
      db:            db_host,
      value:         db_info['db_size'],
      active:        db_info['active'],
      created:       DateTime.now,
      db_resource:   db_resource
    )
  rescue => e # Don't crash on errors
    MyLog.log.error StandardError.new("DBSize:  #{e}: #{db_info}")
    STDERR.puts "DBSize: #{e}: #{db_info}" # Log the error
  end
end
