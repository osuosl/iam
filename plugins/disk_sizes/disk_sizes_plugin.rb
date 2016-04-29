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
    @DB.create_table?(:measurementDiskSizes) do # Plugin's DB model
      primary_key   :id
      foreign_key   NodeResource.name
      Time          :time, null: false
      String        :node
      Integer       :value
    end
  end

  def collect
    # collect method should go here
  end

  def report
    # report method should go here
  end
end
