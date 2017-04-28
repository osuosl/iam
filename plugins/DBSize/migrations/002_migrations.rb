# frozen_string_literal: true
# DBSize's migration file

Sequel.migration do
  transaction
  change do
    alter_table(:db_size_measurements) do # Plugin's DB model
      rename_column :node_resource, :db_resource
    end
  end
end
