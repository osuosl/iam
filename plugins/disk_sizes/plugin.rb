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
    Sequel::Migrator.run(Iam.settings.DB,
                         '/data/code/plugins/disk_sizes/migrations',
                         column: :disk_size_ver
                        )
  end

  def store(fqdn)
    # Get node_resources id that matches fqdn
    resource_id = Iam.settings.DB[:node_resources].where(:name=>fqdn).get(:id)

    # Pull from our cache
    redis = Redis.new(:host => ENV['REDIS_HOST'])

    # Insert data into disk_size_measurements table
    dataset = Iam.settings.DB[:disk_size_measurements]

    node_info = JSON.parse(redis.get(fqdn))
    disk_sizes = node_info['disk_sizes']
    dataset.insert(:node          => fqdn,
                   :value         => eval(disk_sizes).inject(0, :+),
                   :active        => node_info['active'],
                   :created       => DateTime.now,
                   :node_resource => resource_id)
  end

  def report
    # report method should go here
  end
end

