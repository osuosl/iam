# frozen_string_literal: true
Sequel.migration do
  transaction
  change do
    create_table(:clients) do
      primary_key :id
      String      :name, unique: true
      String      :contact_name
      String      :contact_email
      String      :description, text: true
      Boolean     :active, default: true
    end

    create_table(:projects) do
      primary_key :id
      foreign_key :client_id, :clients
      String      :name, unique: true
      String      :resources, size: 255
      String      :description, text: true
      Boolean     :active, default: true
    end

    create_table(:plugins) do
      primary_key :id
      String      :name, unique: true
      String      :resource_name
      String      :storage_table
      String      :units
      Boolean     :active, default: true
    end

    create_table(:node_resources) do
      primary_key :id
      foreign_key :project_id, :projects
      String      :name, unique: true
      String      :type
      String      :cluster
      DateTime    :created
      DateTime    :modified
      Boolean     :active, default: true
    end
  end
end
