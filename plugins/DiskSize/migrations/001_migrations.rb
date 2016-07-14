# DiskSize's migration file

Sequel.migration do
  transaction
  change do
    create_table(:disk_size_measurements) do # Plugin's DB model
      primary_key   :id
      foreign_key   :node_resource
      Time          :created, null: false
      String        :node
      Integer       :disk_count
      Integer       :disk1_size, default: 0
      Integer       :disk2_size, default: 0
      Integer       :disk3_size, default: 0
      Boolean       :active
    end
  end
end
