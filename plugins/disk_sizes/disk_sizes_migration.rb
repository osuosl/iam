# rough draft of migration file
require_relative './disk_sizes_plugin'

DiskSize.DB.create_table?(:measurementDiskSizes) do # Plugin's DB model
  primary_key   :id
  foreign_key   NodeResource.name
  Time          :time, null: false
  String        :node
  Integer       :value
end
