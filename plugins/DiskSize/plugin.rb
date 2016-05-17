require 'sequel'
require_relative '../../environment.rb'
require_relative '../../models.rb'

# Disk Sizes data plugin
class DiskSize
  def initialize
    @redis = Redis.new(host: ENV['REDIS_HOST'])
    @database = Iam.settings.DB
    @table = :disk_size_measurements
    register
  end

  def register
    Plugin.find_or_create(name: 'DiskSize', # create entry in Plugins table
                          resource_name: 'node',
                          storage_table: @table.to_s,
                          units: 'bytes')
    # execute migration
    Sequel::Migrator.run(@database,
                         File.dirname(__FILE__) + '/migrations',
                         column: :disk_size_ver)
  end

  def store(fqdn)
    # Pull node information from redis as a ruby hash
    node_info = JSON.parse(@redis.get(fqdn))

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
      node_resource: @database[:node_resources].where(name: fqdn).get(:id))
  rescue => e        # Don't crash on errors
    STDERR.puts e    # Log the error
  end

  SECONDS_IN_DAY = 60 * 60 * 24
  def report(fqdn = '*', days = 1)
    # return empty if days is not an integer
    return {} unless days.is_a? Integer
    return {} unless fqdn.is_a? String

    # setup time range
    end_time = Time.now
    start_time = Time.now - (days * SECONDS_IN_DAY)

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

