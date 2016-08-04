require 'sequel'
Sequel.extension :migration, :core_extensions

describe 'DB Collector' do
  before(:all) do
    DB = []
    DB[0] = Sequel.connect('mysql://root:toor@testing-mysql')

    [1,2,3,4,5].each do |n|
      puts "Dropping database #{n} on test-mysql"
      DB[0].run "DROP DATABASE IF EXISTS db#{n}"

      puts "Creating database #{n} on test-mysql server"
      DB[0].run "CREATE DATABASE IF NOT EXISTS db#{n};"

      puts "Using database #{n} on testing-mysql"
      DB[n] = Sequel.mysql("db#{n}",
                           :user => 'root',
                           :password => 'toor',
                           :host => 'testing-mysql')

      [11,12,13,15,15].each do |m|
        puts "Creating table ':table_#{m}' on testing-mysql"
        DB[n].create_table "table__#{m}" do
          primary_key :id
          String :name, :null=>false, :unique=>true
        end

        # the table names for creating the dataset need to be symbols,
        # hence the .to_sym.

        dataset = DB[n]["table_#{m}".to_sym]
        dataset.insert(:name => "Fooby-#{n}-#{m}")
        dataset.insert(:name => "Barby-#{n}-#{m}")
