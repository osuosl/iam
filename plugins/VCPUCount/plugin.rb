require 'sequel'
require_relative '../../environment.rb'
require_relative '../../models.rb'

# VCPU Count data plugin
# TODO: If this turns out to be the same for physical CPUs, rename this plugin
#       CPUCount. Leaving it as VCPUCount for now in case VCPUs are billed
#       differently.
class VCPUCount
  def initialize
    @redis = Redis.new(host: ENV['REDIS_HOST'])
    @database = Iam.settings.DB
    @table = :vcpu_count_measurements
    register
  end

  def register
    Plugin.find_or_create(name: 'VCPUCount', # create entry in Plugins table
                          resource_name: 'node',
                          storage_table: @table.to_s,
                          units: 'vcpu')
    # execute migration
    Sequel::Migrator.run(@database,
                         File.dirname(__FILE__) + '/migrations',
                         column: :vcpu_count_ver)
  end

  def store(fqdn)
    # Pull node information from redis as a ruby hash
    node_info = JSON.parse(@redis.get(fqdn))

    # Insert data into disk_size_measurements table
    @database[@table].insert(
      node:          fqdn,
      value:         node_info['num_cpus'].to_i,
      active:        node_info['active'],
      created:       DateTime.now,
      node_resource: @database[:node_resources].where(name: fqdn).get(:id))
  rescue => e        # Don't crash on errors
    STDERR.puts e    # Log the error
  end

  SECONDS_IN_DAY = 60 * 60 * 24
  def report(fqdn = '*', days = 1)
    # setup time range
    end_time = Time.now
    start_time = end_time - (days * SECONDS_IN_DAY)

    # if fqdn is default, return all
    if fqdn == '*'
      dataset = @database[@table].where(created: start_time..end_time)
    # else return data filtered with fqdn name
    else
      dataset = @database[@table].where(node: fqdn)
                                 .where(created: start_time..end_time)
    end
    # format and make json/csv thing
    dataset.all.to_json
  end
end
