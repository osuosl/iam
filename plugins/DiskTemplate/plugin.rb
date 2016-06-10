require 'sequel'
require_relative '../../environment.rb'
require_relative '../../models.rb'
require_relative '../BasePlugin/plugin.rb'

# DiskTemplate plugin
class DiskTemplate < BasePlugin
  def initialize
    @@name = 'DiskTemplate'
    @@resource_name = 'node'
    @@units = 'type'
    @@table = :disk_template_measurements
    @@db_column = :disk_template_ver
    @@migrations_dir = File.dirname(__FILE__) + '/migrations'
    register
  end

  def store(fqdn)
    # Pull node information from redis as a ruby hash
    node_info = JSON.parse(@@redis.get(fqdn))

    # Error check for valid data
    if node_info['disk_template'].nil?
      raise "No disk_template information for #{fqdn}"
    end

    # Insert data into disk_size_measurements table
    @@database[@@table].insert(
      node:          fqdn,
      value:         node_info['disk_template'],
      active:        node_info['active'],
      created:       DateTime.now,
      node_resource: @@database[:node_resources].where(name: fqdn).get(:id))
  rescue => e                        # Don't crash on errors
    STDERR.puts "#{e}: #{node_info}" # Log the error
  end

end
