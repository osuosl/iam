require_relative '../../collectors.rb'
require_relative '../spec_helper.rb'
require 'sequel'
Sequel.extension :migration, :core_extensions

describe 'IaM Database Collector' do
  include Rack::Test::Methods

  before :all do
    # Holds the set of all database connections
    @DB = {}

    # Establishes the main database connection using the root credentials
    # Credentials should probably use env vars and not be hard-coded
    @DB["main"] = Sequel.connect('mysql://root:toor@testing-mysql')

    # Create three databases on the server
    1.upto 3 do |i|
      # These two lines run the following raw SQL on the server
      @DB["main"].run "DROP DATABASE IF EXISTS db#{i}"
      @DB["main"].run "CREATE DATABASE IF NOT EXISTS db#{i};"

      # Connect to each database individually
      @DB[i] = Sequel.mysql("db#{i}", :user => 'root',
                            :password => 'toor',
                            :host => 'testing-mysql')

      # Create i*i tables on each database
      (1..(i*i)).each do |j|
        @DB[i].create_table "table_#{j}" do
          primary_key :id
          String :name, :null=>false, :unique=>true
        end

	# Note: The table names for creating the dataset need to be symbols,
	# hence the .to_sym.
        dataset = @DB[i][:"table_#{j}"]
	# Insert i*i records in each of the i*i tables on each of the three
	# databases
        (1..(i*i)).each do |k|
          dataset.insert(:name => "data-#{k}")
        end
      end
    end

    @expected = []
    # This query produces a set of hashes
    # { :'DB Name' => 'some name', :'Data Base Size in Bytes' => '#####'}
    # etc
    @DB["main"].fetch "SELECT
                      table_schema
                        'DB Name',
                      cast(round(sum(data_length+index_length),1) as binary)
                        'Data Base Size in Bytes'
                      FROM information_schema.TABLES
                      GROUP BY table_schema" do |var|
      @expected.push(var)
    end
    # Uncomment this line to see what the above query gets us
    # puts @expected
  end

  after :all do
    # Drop all of the databases so our tests are idempotent 
    [1,2,3].each do |n|
      @DB["main"].run "DROP DATABASE IF EXISTS db#{n}"
    end
  end

  it 'collects the correct data using the given query' do
    c = Collectors.new
    c.collect_db
    cache = Cache.new(ENV['CACHE_FILE'])
    expect(@expected).to eq(cache.dump)
  end

  it 'raises an error  when it is unable to connect to the database' do
    # change parameters here
    # need to implement database collector to be able to set 
    # uri/user/password that will trigger the error 
    # after that:
    c = Collectors.new
    expect do
      c.collect_db
    end.to raise_error(Sequel::DatabaseConnectionError)
  end

  # any other tests we should include? I can't think of any.
end
