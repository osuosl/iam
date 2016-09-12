require 'logging'
require 'sequel'
require_relative '../../lib/BasePlugin/plugin.rb'
require_relative '../../environment.rb'
require_relative '../../models.rb'
require_relative '../../logging/logs'

# Disk Sizes data plugin
class DiskSize < BasePlugin
  def initialize
    name = 'DiskSize'
    resource_name = 'node'
    units = 'bytes'
    table = :disk_size_measurements
    db_column = :disk_size_ver
    migrations_dir = File.dirname(__FILE__) + '/migrations'

    super(name, resource_name, units, table, db_column, migrations_dir)
    register
  end

  # rubocop: disable MethodLength, AbcSize
  def store(fqdn)
    # Pull node information from cache as a ruby hash
    node_info = @cache.get(fqdn)

    # Check for valid data
    if node_info['disk_sizes'].nil? || node_info['disk_sizes'] == 'unknown'
      MyLog.log.warn "DiskSize: No disk_sizes information for #{fqdn}"
      raise "DiskTemplate: No disk_template information for #{fqdn}"
    end

    # Insert data into disk_size_measurements table
    @database[@table].insert(
      node:          fqdn,
      value:         node_info['disk_sizes']
                       .tr('[]', '')    # remove '[' and ']' from string
                       .split(',')      # split into array of strings on ','
                       .map(&:to_i)     # convert each element to integer
                       .inject(0, :+),  # inject a + method to sum the array
      active:        node_info['active'],
      created:       DateTime.now,
      node_resource: @database[:node_resources].where(name: fqdn).get(:id)
    )
  rescue => e # Don't crash on errors
    MyLog.log.error StandardError.new("DiskSize:  #{e}: #{node_info}")
  end
end
