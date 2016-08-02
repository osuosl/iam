require_relative '../../collectors.rb'
require_relative '../spec_helper.rb'

describe 'The Database Collector' do
  def app
    Iam
  end

  include Rack::Test::Methods
  # We might want to change this to `before :all` to speed tests up
  before :all do
    # mysql://MYSQL_USER:MYSQL_PASSWORD@testing-mysql/MYSQL_DATABASE
    @mysql = Sequel.mysql(ENV['MYSQL_DATABASE'],              # MySQL testing datbase name
                          :user     => ENV['MYSQL_USER'],     # MySQL testing user
                          :password => ENV['MYSQL_PASSWORD'], # MySQL testing user passphrase
                          :host     => 'testing-mysql')       # MySQL testing host
    # postgres://POSTGRES_USER:POSTGRES_PASSWORD@testing-psql/POSTGRES_DB
    @psql = Sequel.postgres(ENV['POSTGRES_DB'],                    # Postgres testing database
                            :user     => ENV['POSTGRES_USER'],     # Postgres testing user 
                            :password => ENV['POSTGRES_PASSWORD'], # Postgres testing user passphrase
                            :host     => 'testing-psql')           # Postgres testing host
    @table1_data = [ ]
    @table2_data = [ ]
    @table3_data = [ ]
  end

  before :each do
    # Runs migrations on the databases since they should be empty each test.
    # Dummy table being created, correct this once we know what the actual
    # tables look like so we can mock it correctly
    [@mysql, @psql].each do |db|
      db.create_table :table1 do
        primary_key :id
        String :name, :null=>false, :unique=>true
      end

      db.create_table :table2 do
        primary_key :id
        String :name, :null=>false, :unique=>true
      end

      db.create_table :table3 do
        primary_key :id
        String :name, :null=>false, :unique=>true
      end
    end
  end

  # Again, might want to make this `after :all` to speed tests up
  after :each do
    # Deletes the database after each test to clean the slate.
    [@mysql, @psql].each do |db|
      db.drop_table :table1
      db.drop_table :table2
      db.drop_table :table3
    end
  end

  # These tests are there to verify that the IaM DB collector correctly queries
  # databases and stores the important information in the cache (?).
end
