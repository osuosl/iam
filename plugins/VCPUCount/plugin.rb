require 'sequel'
require 'logging'
require_relative '../../lib/BasePlugin/plugin.rb'
require_relative '../../environment.rb'
require_relative '../../models.rb'

# VCPU Count data plugin
# TODO: If this turns out to be the same for physical CPUs, rename this plugin
#       CPUCount. Leaving it as VCPUCount for now in case VCPUs are billed
#       differently.
class VCPUCount < BasePlugin
  def initialize
    @@name = 'VCPUCount'
    @@resource_name = 'node'
    @@units = 'vcpu'
    @@table = :vcpu_count_measurements
    @@db_column = :vcpu_count_ver
    @@migrations_dir= File.dirname(__FILE__) + '/migrations'
    @@database = Iam.settings.DB
    @@table = :vcpu_count_measurements
    @cache = Cache.new(ENV['CACHE_FILE'])
    register
  end

  def store(fqdn)
    # Pull node information from cache as a ruby hash
    node_info = @cache.get(fqdn)

    # Error check for valid data
    if node_info['num_cpus'].nil? || node_info['num_cpus'] == 'unknown'
      log.warn "No num_cpus information for #{fqdn}"
      raise "No num_cpus information for #{fqdn}"
    end

    # Insert data into disk_size_measurements table
    @@database[@@table].insert(
      node:          fqdn,
      value:         node_info['num_cpus'].to_i,
      active:        node_info['active'],
      created:       DateTime.now,
      node_resource: @@database[:node_resources].where(name: fqdn).get(:id))
  rescue => e                        # Don't crash on errors
    log.error StandardError.new("#{e}: #{node_info}")
  end
end
