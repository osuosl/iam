require 'sequel'
require_relative '../../environment.rb'
require_relative '../../models.rb'

# Disk Sizes data plugin
class DiskSize
  def register
    Plugin.find_or_create(name: 'DiskSizes', # create entry in Plugins table
                          resource_name: 'node',
                          storage_table: 'disk_sizes',
                          units: 'bytes')
    # execute migration
    Sequel::Migrator.run(Iam.settings.DB,
                         '/data/code/plugins/disk_sizes/migrations',
                         column: :diskSize_ver
                        )
  end

  def collect
    # collect method should go here
  end
  
  SECONDS_IN_DAY = 60 * 60 * 24
  def report(fqdn = '*', days = 1)
    # setup time range
    end_time = Time.now
    start_time = Time.now - (days * SECONDS_IN_DAY)

    # go into db table,
    data_table = Iam.settings.DB[:measurementDiskSizes]
    # if fqdn is default, return all
    if fqdn == '*'
      dataset = data_table.where(time: start_time..end_time)
    # else return data filtered with fqdn name
    else
      dataset = data_table.where(node: fqdn)
                          .where(time: start_time..end_time)
    end
    # format and make json/csv thing
    puts dataset.all.to_json
  end
end

# Uncomment to test:
# DiskSize.new.register
