require 'sequel'
require_relative '../../environment.rb'
require_relative '../../models.rb'
require_relative '../BasePlugin/plugin.rb'

# VCPU Count data plugin
# TODO: If this turns out to be the same for physical CPUs, rename this plugin
#       CPUCount. Leaving it as VCPUCount for now in case VCPUs are billed
#       differently.
class VCPUCount < BasePlugin
  def initialize
    @name = 'VCPUCount'
    @resource_name = 'node'
    @units = 'vcpu'
    @table = :vcpu_count_measurements
    @db_column = :vcpu_count_ver
    @current_dir = File.dirname(__FILE__)
    register
  end

  def register
    super()
  end

  def store(fqdn)
    # Pull node information from redis as a ruby hash
    node_info = JSON.parse(@redis.get(fqdn))

    # Error check for valid data
    if node_info['num_cpus'].nil? || node_info['num_cpus'] == 'unknown'
      raise "No num_cpus information for #{fqdn}"
    end

    # Insert data into disk_size_measurements table
    @@database[@table].insert(
      node:          fqdn,
      value:         node_info['num_cpus'].to_i,
      active:        node_info['active'],
      created:       DateTime.now,
      node_resource: @@database[:node_resources].where(name: fqdn).get(:id))
  rescue => e                        # Don't crash on errors
    STDERR.puts "#{e}: #{node_info}" # Log the error
  end

  def report(fqdn = '*', days = 1)
    # setup time range
    end_time = Time.now
    start_time = end_time - (days * SECONDS_IN_DAY)

    # if fqdn is default, return all
    if fqdn == '*'
      dataset = @@database[@table].where(created: start_time..end_time)
    # else return data filtered with fqdn name
    else
      dataset = @@database[@table].where(node: fqdn)
                                 .where(created: start_time..end_time)
    end
    # format and make json/csv thing
    dataset.all.to_json
  end
end
