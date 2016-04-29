require 'sequel'
require_relative '../../environment.rb'
require_relative '../../models.rb'

# Disk Sizes data plugin
class DiskSize
  def initialize
    @DB = Iam.settings.DB
  end

  def register
    Plugin.create(name: 'DiskSizes', # create entry in Plugins table
                  resource_name: 'node',
                  storage_table: 'disk_sizes',
                  units: 'bytes')
    # execute migration
    require_relative './disk-sizes_migration.rb'
  end

  def collect
    # collect method should go here
  end

  def report
    # report method should go here
  end
end
