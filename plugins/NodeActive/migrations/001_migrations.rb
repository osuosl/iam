# frozen_string_literal: true
# NodeActive's migration file

Sequel.migration do
  transaction
  change do
    create_table(:node_active_measurements) do # Plugin's DB model
      primary_key   :id
      foreign_key   :node_resource
      Time          :created, null: false
      String        :node
      Boolean       :value
    end
  end
end
