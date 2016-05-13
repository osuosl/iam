require 'sequel'
require_relative '../../environment.rb'
require_relative '../../models.rb'

# Disk Sizes data plugin
class DiskSize
  def register
    Plugin.find_or_create(name: 'disk_size', # create entry in Plugins table
                          resource_name: 'node',
                          storage_table: 'disk_size_measurements',
                          units: 'bytes')
    # execute migration
    path = File.dirname(__FILE__) + '/migrations'
    Sequel::Migrator.run(Iam.settings.DB,
                         path,
                         column: :disk_size_ver)
  end

  def store(fqdn)
    # Get node_resources id that matches fqdn
    resource_id = Iam.settings.DB[:node_resources].where(name: fqdn).get(:id)

    # Pull from our cache
    redis = Redis.new(host: ENV['REDIS_HOST'])

    # Insert data into disk_size_measurements table
    dataset = Iam.settings.DB[:disk_size_measurements]

    node_info = JSON.parse(redis.get(fqdn))

    # Remove brackets then split on ',' to create an array
    disk_sizes = node_info['disk_sizes'].tr('[]', '').split(',').map(&:to_i)

    # Insert data into disk_size_measurements table
    dataset.insert(node:          fqdn,
                   value:         disk_sizes.inject(0, :+),
                   active:        node_info['active'],
                   created:       DateTime.now,
                   node_resource: resource_id)
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

# Uncomment to test:
# DiskSize.new.register
# puts DiskSize.new.report('FACEYMYBOOKY.com', 1)
# puts DiskSize.new.report
