# frozen_string_literal: true
# example of
# 1. Connecting to a mysql database server
# 2. Creating five databases on that server
# 3. Creating five tables on each of those databases
# 4. Populating each of those five tables with some dummy data
# 5. Printing that data out
# 6. Dropping the databases
require 'sequel'
Sequel.extension :migration, :core_extensions

db_ = []

# Just connect to the database server, not a particular db_ on the server
db_[0] = Sequel.connect("mysql://#{ENV['MYSQL_USER']}:#{ENV['MYSQL_PASSWORD']}@\
  #{ENV['MYSQL_TESTING_HOST']}")

# Create tables db1, db2, db3, db4, and db5 on the server
[1, 2, 3, 4, 5].each do |n|
  # Wipe the database from the server.
  # Clean slate.
  puts "Dropping database #{n} on testing-mysql"
  db_[0].run "DROP DATABASE IF EXISTS db#{n}"

  # Create the database on the server to start doing the thing.
  puts "Creating database #{n} on testing-mysql server"
  db_[0].run "CREATE DATABASE IF NOT EXISTS db#{n};"

  # Connect to the specific database on the server.
  puts "Using database #{n} on testing-mysql"
  db_[n] = Sequel.mysql("db#{n}",
                        user: ENV['MYSQL_USER'],
                        password: ENV['MYSQL_PASSWORD'],
                        host: ENV['MYSQL_TESTING_HOST'])

  # Create tables table_11, table_12, table_13, table_14, and table_15.
  [11, 12, 13, 14, 15].each do |m|
    puts "Creating table ':table_#{m}' on testing-mysql"
    db_[n].create_table "table_#{m}" do
      primary_key :id
      String :name, null: false, unique: true
    end

    # For each of the tables populate it with unique data.
    # The table names for creating the dataset need to be symbols,
    # hence the .to_sym.
    dataset = db_[n]["table_#{m}".to_sym]
    dataset.insert(name: "Fooby-#{n}-#{m}")
    dataset.insert(name: "Barby-#{n}-#{m}")
    dataset.insert(name: "Bazby-#{n}-#{m}")

    # Print what we just wrote to the database.
    dataset.each do |e|
      puts e
    end
  end

  puts "Disconnecting from database #{n} on testing-mysql"
  db_[n].disconnect

  # Wipe the database at the end. Clean slate.
  # Q: Why do we drop the datbase from the server twice?
  # A: So if we make changes to the schema it doesn't cause us to manually
  # create a new database.
  puts "Dropping database #{n} on testing-mysql"
  db_[0].run "DROP DATABASE IF EXISTS db#{n}"
end
