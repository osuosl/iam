require 'sequel'
require_relative '../../environment.rb'
require_relative '../../models.rb'

# Disk Sizes data plugin
class DiskSize
  def initialize
    @redis = Redis.new(host: ENV['REDIS_HOST'])
    @dataset = Iam.settings.DB
    register
  end

  def register
    Plugin.find_or_create(name: 'DiskSize', # create entry in Plugins table
                          resource_name: 'node',
                          storage_table: 'disk_size_measurements',
                          units: 'bytes')
    # execute migration
    Sequel::Migrator.run(Iam.settings.DB,
                         File.dirname(__FILE__) + '/migrations',
                         column: :disk_size_ver)
  end

  def store(fqdn)
    # Pull node information from redis as a ruby hash
    node_info = JSON.parse(@redis.get(fqdn))

    # Insert data into disk_size_measurements table
    @dataset[:disk_size_measurements].insert(
      node:          fqdn,
      value:         node_info['disk_sizes']
                       .tr('[]', '').split(',').map(&:to_i).inject(0, :+),
      active:        node_info['active'],
      created:       DateTime.now,
      node_resource: @dataset[:node_resources].where(name: fqdn).get(:id))
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

    # go into db table,
    data_table = Iam.settings.DB[:disk_size_measurements]
    # if fqdn is default, return all
    if fqdn == '*'
      dataset = data_table.where(created: start_time..end_time)
    # else return data filtered with fqdn name
    else
      dataset = data_table.where(node: fqdn)
                          .where(created: start_time..end_time)
    end
    # format and make json/csv thing
    dataset.all.to_json
  end

end

