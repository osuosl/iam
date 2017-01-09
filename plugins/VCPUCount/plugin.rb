require 'sequel'
require 'logging'
require_relative '../../lib/BasePlugin/plugin.rb'
require_relative '../../environment.rb'
require_relative '../../models.rb'
require_relative '../../logging/logs'

# VCPU Count data plugin
# TODO: If this turns out to be the same for physical CPUs, rename this plugin
#       CPUCount. Leaving it as VCPUCount for now in case VCPUs are billed
#       differently.
class VCPUCount < BasePlugin
  def initialize
    name = 'VCPUCount'
    resource_name = 'node'
    units = 'vcpu'
    table = :vcpu_count_measurements
    db_column = :vcpu_count_ver
    migrations_dir = File.dirname(__FILE__) + '/migrations'

    super(name, resource_name, units, table, db_column, migrations_dir)
    register
  end

  # rubocop: disable MethodLength, AbcSize
  def store(fqdn)
    # Pull node information from cache as a ruby hash
    node_info = @cache.get(fqdn)

    # Error check for valid data
    if node_info['num_cpus'].nil? || node_info['num_cpus'] == 'unknown'
      MyLog.log.warn "VCPUCount: No num_cpus information for #{fqdn}"
      raise "VCPUCount: No num_cpus information for #{fqdn}"
    end

    # check if node resource exist, otherwise set it to default
    node_resource = @database[:node_resources].where(name: fqdn).get(:id)
    node_resource = default_node(fqdn, node_info['type'],
                                 node_info['cluster']) unless node_resource

    # Insert data into disk_size_measurements table
    @database[@table].insert(
      node:          fqdn,
      value:         node_info['num_cpus'].to_i,
      active:        node_info['active'],
      created:       DateTime.now,
      node_resource: node_resource
    )
  rescue => e # Don't crash on errors
    MyLog.log.error StandardError.new("VCPUCount:  #{e}: #{node_info}")
  end
end
