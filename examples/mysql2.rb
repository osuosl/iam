# example of
# 1. Connecting to a mysql database server
# 2. Creating five databases on that server
# 3. Creating five tables on each of those databases
# 4. Populating each of those five tables with some dummy data
# 5. Printing that data out
# 6. Dropping the datbases
require 'sequel'
Sequel.extension :migration, :core_extensions

DB = []

# Just connect to the database server, not a particular DB on the server
DB[0] = Sequel.connect('mysql://root:toor@testing-mysql')

[1,2,3,4,5].each do |n|
  puts "Dropping database #{n} on testing-mysql"
  DB[0].run "DROP DATABASE IF EXISTS db#{n}"

  puts "Creating database #{n} on testing-mysql server"
  DB[0].run "CREATE DATABASE IF NOT EXISTS db#{n};"

  puts "Using database #{n} on testing-mysql"
  DB[n] = Sequel.mysql("db#{n}",
                       :user => 'root',
                       :password => 'toor',
                       :host => 'testing-mysql')

  [11,12,13,14,15].each do |m|
    puts "Creating table ':table_#{m}' on testing-mysql"
    DB[n].create_table "table_#{m}" do
      primary_key :id
      String :name, :null=>false, :unique=>true
    end

    # the table names for creating the dataset need to be symbols,
    # hence the .to_sym.
    dataset = DB[n]["table_#{m}".to_sym]
    dataset.insert(:name => "Fooby-#{n}-#{m}")
    dataset.insert(:name => "Barby-#{n}-#{m}")
    dataset.insert(:name => "Bazby-#{n}-#{m}")

    dataset.each do |e|
      puts e
    end
  end

  puts "Disconnecting from database #{n} on testing-mysql"
  DB[n].disconnect

  puts "Dropping database #{n} on testing-mysql"
  DB[0].run "DROP DATABASE IF EXISTS db#{n}"
end
