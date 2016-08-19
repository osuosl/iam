require 'sequel'
require_relative '../../lib/BasePlugin/plugin.rb'
require_relative '../../environment.rb'
require_relative '../../models.rb'

# DBSizes data plugin
class DBSize < BasePlugin
  def initialize
    @@name = 'DBSize'
    @@resource_name = 'db'
    @@units = 'bytes'
    @@table = :db_size_measurements
    @@db_column = :db_size_ver
    @@migrations_dir = File.dirname(__FILE__) + '/migrations'
    @@database = Iam.settings.DB
    @cache = Cache.new(ENV['CACHE_FILE'])
    register
  end

  def store(db_host)
    # Pull node information from cache as a ruby hash
    db_info = @cache.get(db_host)
    db_key = 'Data Base Size in Bytes'

    # Check for valid data
    if db_info[db_key].nil? || db_info[db_key] == ''
      raise "No DBSize information for #{db_host}\n"
    elsif not db_info[db_key].is_number?
      raise "DB information for #{db_host} malformed (should be a number)\n"
    end

    # Insert data into db_size_measurements table
    @@database[@@table].insert(
      db:            db_host,
      value:         db_info[db_key],
      active:        1,
      created:       DateTime.now,
      node_resource: @@database[:node_resources].where(name: db_host).get(:id))
  rescue => e                        # Don't crash on errors
    STDERR.puts "#{e}: #{db_info}" # Log the error
  end
end
