require 'sequel'
require_relative '../../environment.rb'
require_relative '../../models.rb'
require_relative '../../lib/cache.rb'

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

    # Insert data into disk_size_measurements table
    @@database[@@table].insert(
      node:          fqdn,
      value:         node_info['disk_sizes']
                       .tr('[]', '')    # remove '[' and ']' from string
                       .split(',')      # split into array of strings on ','
                       .map(&:to_i)     # convert each element to integer
                       .inject(0, :+),  # inject a + method to sum the array
      active:        node_info['active'],
      created:       DateTime.now,
      node_resource: @@database[:node_resources].where(name: fqdn).get(:id))
  rescue => e                        # Don't crash on errors
    STDERR.puts "#{e}: #{node_info}" # Log the error
  end
end
