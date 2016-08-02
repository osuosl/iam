require 'sequel'
Sequel.extension :migration, :core_extensions

DB = Sequel.mysql('test_db', :user => 'test_db_user', :password => 'test_db_pass', :host => 'testing-mysql')

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

DB.fetch("SELECT table_schema 'DB Name', cast(round(sum( data_length + index_length ) , 1) as binary) 'Data Base Size in Bytes' FROM information_schema.TABLES GROUP BY table_schema") do |e|
  puts e
end

DB.drop_table :items
