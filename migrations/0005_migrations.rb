# frozen_string_literal: true
Sequel.migration do
  transaction
  change do
    create_table(:skus) do
      primary_key :id
      foreign_key :node_resource_project_id, :node_resources_projects
      foreign_key :db_resource_project_id, :db_resources_projects
      Integer     :sku_num
      String      :name, unique: true
      String      :description
      String      :family
      Float       :rate
      Boolean     :active, default: true
    end
  end
end
