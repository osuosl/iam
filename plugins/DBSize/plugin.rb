require 'sequel'
require_relative '../../lib/BasePlugin/plugin.rb'
require_relative '../../environment.rb'
require_relative '../../models.rb'

# Disk Sizes data plugin
class DBSize < BasePlugin
  def initialize
    @@name = 'DBSize'
    @@resource_name = 'node'
    @@units = 'bytes'
    @@table = :db_size_measurements
    @@db_column = :db_size_ver
    @@migrations_dir = File.dirname(__FILE__) + '/migrations'
    @@database = Iam.settings.DB
    @cache = Cache.new(ENV['CACHE_FILE'])
    register
  end

  def store(fqdn)
    # Pull node information from cache as a ruby hash
    node_info = @cache.get(fqdn)
    db_key = 'Data Base Size in Bytes'
    # Check for valid data
    if node_info[db_key].nil? || node_info[db_key] == ''
      raise "No DBSize information for #{fqdn}\n"
    end

    # Insert data into disk_size_measurements table
    @@database[@@table].insert(
      node:          fqdn,
      value:         node_info[db_key],
      active:        1,
      created:       DateTime.now,
      node_resource: @@database[:node_resources].where(name: fqdn).get(:id))
  rescue => e                        # Don't crash on errors
    STDERR.puts "#{e}: #{node_info}" # Log the error
  end
end
