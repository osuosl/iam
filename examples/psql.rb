# Example of using Sequel to connect to and work with a Postgres database.
# The PostgreSQL database is running in a linked docker container at the host
# `testing-psql`

require 'sequel'
Sequel.extension :migration, :core_extensions

# Missing: Creating multiple databases on the `testing-psql` server.

# Make the connection to the database.
DB = Sequel.postgres('test_db',
                     :user => 'test_db_user',
                     :password => 'test_db_pass',
                     :host => 'testing-psql')

# Run migrations on the database, create `items` table.
DB.create_table :items do
  primary_key :id
  String :name, :null=>false, :unique=>true
end

# Get a dataset from the database and insert an element into the database.
dataset = DB[:items]
dataset.insert(:name => 'Fooby')
dataset.insert(:name => 'Barby')
dataset.insert(:name => 'Bazby')

# Print the contents of the database.
dataset.each do |e|
  puts e
end

# this line works in mysql.rb but not psql.rb, need to determine the
# differences. In the meantime we only care about mysql to start with so psql
# is a lower priority
#DB.fetch("SELECT table_schema 'DB Name', round(sum( data_length + index_length
#        ) , 1) 'Data Base Size in Bytes' FROM information_schema.TABLES GROUP
#        BY table_schema") do |e|
#  puts e
#end

# Drop the tables created.
DB.drop_table :items
