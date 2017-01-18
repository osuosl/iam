Sequel.migration do
  transaction
  change do
    create_table(:collector_stats) do
      primary_key :id
      String      :name
      DateTime    :created
      Time        :start
      Time        :end
      Integer     :duration
      Boolean     :success
    end
  end
end
