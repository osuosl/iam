# frozen_string_literal: true
Sequel.migration do
  transaction
  change do
    create_table(:db_resources) do
      primary_key :id
      foreign_key :project_id, :projects
      String      :name, unique: true
      String      :type
      String      :server
      DateTime    :created
      DateTime    :modified
      Boolean     :active, default: true
    end
  end
end
