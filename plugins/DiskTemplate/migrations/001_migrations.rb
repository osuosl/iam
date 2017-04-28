# frozen_string_literal: true
# Disk_Size's migration file

Sequel.migration do
  transaction
  change do
    create_table(:disk_template_measurements) do # Plugin's DB model
      primary_key   :id
      foreign_key   :node_resource
      Time          :created, null: false
      String        :node
      String        :value
      Boolean       :active
    end
  end
end
