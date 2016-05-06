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

  def report
    # report method should go here
  end
end

# Uncomment to test:
# DiskSize.new.register
