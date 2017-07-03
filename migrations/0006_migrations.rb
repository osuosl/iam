# frozen_string_literal: true
Sequel.migration do
  transaction
  change do
    alter_table(:db_resources_projects) do
      add_foreign_key :sku_id, :skus
    end
    alter_table(:node_resources_projects) do
      add_foreign_key :sku_id, :skus
    end
  end
end
