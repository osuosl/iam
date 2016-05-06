# Disk_Size's migration file

Sequel.migration do
  transaction
  change do
    create_table(:measurementDiskSizes) do # Plugin's DB model
      primary_key   :id
      foreign_key   :node_resource
      Time          :time, null: false
      String        :node
      Integer       :value
    end
  end
end
