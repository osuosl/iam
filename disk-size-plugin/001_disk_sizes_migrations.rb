Sequel.migration do
  transaction
  change do
    create_table(:disk_size_measurements) do
      primary_key :id
      foreign_key :resource_id, :node_resources
      String      :value
      Boolean     :active
      DateTime    :created
    end
  end
end
