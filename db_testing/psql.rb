require 'sequel'
Sequel.extension :migration, :core_extensions

DB = Sequel.postgres('test_db', :user => 'test_db_user', :password => 'test_db_pass', :host => 'testing-psql')

DB.create_table :items do
  primary_key :id
  String :name, :null=>false, :unique=>true
end

dataset = DB[:items]
dataset.insert(:name => 'fooby')

dataset.each do |e|
  puts e
end

dataset = []

# this line works in mysql.rb but not psql.rb, need to determine the
# differences. In the meantime we only care about mysql to start with so psql
# is a lower priority
#DB.fetch("SELECT table_schema 'DB Name', round(sum( data_length + index_length ) , 1) 'Data Base Size in Bytes' FROM information_schema.TABLES GROUP BY table_schema") do |e|
#  puts e
#end

DB.drop_table :items
