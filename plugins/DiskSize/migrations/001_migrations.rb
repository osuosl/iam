# frozen_string_literal: true
# DiskSize's migration file

Sequel.migration do
  transaction
  change do
    create_table(:disk_size_measurements) do # Plugin's DB model
      primary_key   :id
      foreign_key   :node_resource
      Time          :created, null: false
      String        :node
      Integer       :value
      Boolean       :active
    end
  end
end
