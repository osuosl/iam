# frozen_string_literal: true
Sequel.migration do
  transaction
  change do
    create_table(:db_resources_projects) do
      primary_key :id
      foreign_key :db_resource_id, :db_resources
      foreign_key :project_id, :projects
    end

    create_table(:node_resources_projects) do
      primary_key :id
      foreign_key :project_id, :projects
      foreign_key :node_resource_id, :node_resources
    end
  end
end
