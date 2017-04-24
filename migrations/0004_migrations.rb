Sequel.migration do
  transaction
  change do
    create_table(:db_resources_projects) do
      primary_key :id
      foreign_key :project_id, :projects
      foreign_key :db_resources_id, :db_resources
    end

    create_table(:node_resources_projects) do
      primary_key :id
      foreign_key :project_id, :projects
      foreign_key :node_resources_id, :node_resources
    end
  end
end
