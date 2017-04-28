# frozen_string_literal: true
# Example of using Sequel to connect to and work with a MySQL database.
# The MySQL database is running in a linked docker container at the host
# `testing-mysql`

require 'sequel'
Sequel.extension :migration, :core_extensions

# Missing: Creating multiple databases on the `testing-mysql` server.

# Make the connection to the database.
DB = Sequel.mysql('test_db',
                  user: 'test_db_user',
                  password: 'test_db_pass',
                  host: 'testing-mysql')

# Run migrations on the database, create `items` table.
DB.create_table :items do
  primary_key :id
  String :name, null: false, unique: true
end

# Get a dataset from the database and insert an element into the database.
dataset = DB[:items]
dataset.insert(name: 'Fooby')
dataset.insert(name: 'Barby')
dataset.insert(name: 'Bazby')

# Print the contents of the database.
dataset.each do |e|
  puts e
end

# This query is very similar to the one used to measure the size of each
# database on a server. This is what the Database collector reports.
DB.fetch("SELECT table_schema 'DB Name', cast(round(sum( data_length +
         index_length ) , 1) as binary) 'Data Base Size in Bytes' FROM
         information_schema.TABLES GROUP BY table_schema") do |e|
  puts e
end

# Drop the tables created.
DB.drop_table :items
