# frozen_string_literal: true
require 'sequel'
require 'logging'
require_relative '../../lib/BasePlugin/plugin.rb'
require_relative '../../environment.rb'
require_relative '../../models.rb'
require_relative '../../logging/logs'

# DiskTemplate plugin
class DiskTemplate < BasePlugin
  def initialize
    name = 'DiskTemplate'
    resource_name = 'node'
    units = 'type'
    table = :disk_template_measurements
    db_column = :disk_template_ver
    migrations_dir = File.dirname(__FILE__) + '/migrations'

    super(name, resource_name, units, table, db_column, migrations_dir)
    register
  end

  # rubocop: disable MethodLength, AbcSize
  def store(fqdn)
    # Pull node information from cache as a ruby hash
    node_info = @cache.get(fqdn)

    # Error check for valid data
    if node_info['disk_template'].nil?
      MyLog.log.warn "DiskTemplate: No disk_template information for #{fqdn}"
      raise "DiskTemplate: No disk_template information for #{fqdn}"
    end

    # check if node resource exist, otherwise set it to default
    node_resource = @database[:node_resources].where(name: fqdn).get(:id)
    node_resource = default_node(fqdn, node_info['type'],
                                 node_info['cluster']) unless node_resource

    # Insert data into disk_size_measurements table
    @database[@table].insert(
      node:          fqdn,
      value:         node_info['disk_template'],
      active:        node_info['active'].true?,
      created:       DateTime.now,
      node_resource: node_resource
    )
  rescue => e # Don't crash on errors
    MyLog.log.error StandardError.new("DiskTemplate:  #{e}: #{node_info}")
  end
end
