require 'sequel'
require_relative '../../lib/BasePlugin/plugin.rb'
require_relative '../../environment.rb'
require_relative '../../models.rb'

# Disk Sizes data plugin
class DiskSize < BasePlugin
  def initialize
    @@name = 'DiskSize'
    @@resource_name = 'node'
    @@units = 'bytes'
    @@table = :disk_size_measurements
    @@db_column = :disk_size_ver
    @@migrations_dir = File.dirname(__FILE__) + '/migrations'
    @@database = Iam.settings.DB
    @cache = Cache.new(ENV['CACHE_FILE'])
    register
  end

  def store(fqdn)
    # Pull node information from cache as a ruby hash
    node_info = @cache.get(fqdn)

    # Check for valid data
    if node_info['disk_sizes'].nil? || node_info['disk_sizes'] == 'unknown'
      raise "No disk_sizes information for #{fqdn}"
    end

    # prep data for DB insert
    # get array length and data formatted
    count = node_info['disk_sizes'].split.length
    values = node_info['disk_sizes'].tr('[]', '')    # remove '[' and ']'
                                    .split(',')      # split into array
                                    .map(&:to_i)     # convert to integer

    # Insert data into disk_size_measurements table
    @@database[@@table].insert(
      node:          fqdn,
      disk_count:    count,
      disk1_size:    values[0] || 0,
      disk2_size:    values[1] || 0,
      disk3_size:    values[2] || 0,
      active:        node_info['active'],
      created:       DateTime.now,
      node_resource: @@database[:node_resources].where(name: fqdn).get(:id))
  rescue => e                        # Don't crash on errors
    STDERR.puts "#{e}: #{node_info}" # Log the error
  end
end
