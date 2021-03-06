# frozen_string_literal: true
require 'logging'
require 'sequel'
require_relative '../../lib/BasePlugin/plugin.rb'
require_relative '../../environment.rb'
require_relative '../../models.rb'
require_relative '../../logging/logs'

# Disk Sizes data plugin
class NodeActive < BasePlugin
  def initialize
    name = 'NodeActive'
    resource_name = 'node'
    units = 'boolean'
    table = :node_active_measurements
    db_column = :node_active_ver
    migrations_dir = File.dirname(__FILE__) + '/migrations'

    super(name, resource_name, units, table, db_column, migrations_dir)
    register
  end

  # rubocop: disable MethodLength, AbcSize
  def store(fqdn)
    # Pull node information from cache as a ruby hash
    node_info = @cache.get(fqdn)

    # Check for valid data
    if node_info['active'].nil? || node_info['active'] == 'unknown'
      puts "NodeActive: No node state information for #{fqdn}"
      MyLog.log.warn "NodeActive: No node state information for #{fqdn}"
      raise "NodeActive: No active information for #{fqdn}"
    end

    # check if node resource exist, otherwise set it to default
    node_resource = @database[:node_resources].where(name: fqdn).get(:id)
    node_resource = default_node(fqdn, node_info['type'],
                                 node_info['cluster']) unless node_resource

    # Insert data into disk_size_measurements table
    @database[@table].insert(
      node:          fqdn,
      value:         node_info['active'],
      created:       DateTime.now,
      node_resource: node_resource
    )
  rescue => e # Don't crash on errors
    MyLog.log.error StandardError.new("NodeActive:  #{e}: #{node_info}")
    puts "#{e}: #{node_info}"
  end
end
