# frozen_string_literal: true
# Disk_Size's migration file

Sequel.migration do
  transaction
  change do
    create_table(:test_plugin_measurements) do # Plugin's DB model
      primary_key   :id
      Time          :created, null: false
      String        :resource
      Integer       :value
    end
  end
end
