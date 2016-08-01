require 'sequel'
Sequel.extension :migration, :core_extensions

DB = Sequel.postgres('test_db', :user => 'test_db_user', :password => 'test_db_pass', :host => 'testing-psql')

Sequel::Migrator.run(DB, 'migrations', :use_transactions=>true)

dataset = DB[:items]
dataset.insert(:name => 'fooby')

dataset.each do |e| 
  puts e
end
