# DBSize's migration file

Sequel.migration do
  transaction
  change do
    create_table(:db_size_measurements) do # Plugin's DB model
      primary_key   :id
      foreign_key   :node_resource
      Time          :created, null: false
      String        :db
      Integer       :value
      Boolean       :active
    end
  end
end
