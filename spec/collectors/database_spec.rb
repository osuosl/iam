require_relative '../../collectors.rb'
require_relative '../spec_helper.rb'
require 'sequel'
Sequel.extension :migration, :core_extensions

describe 'IaM Database Collector' do
  include Rack::Test::Methods

  before :all do
    # Holds the set of all database connections
    # rubocop:disable VariableName
    @DB = {}
    # rubocop:enable VariableName

    # skip this test if a mysql test server is not available
    skip('no testing db available') unless ENV['TEST_MYSQL_DB']

    # Grant complete privileges to our special user
    command = "mysql://root:#{ENV['TEST_MYSQL_ROOT_PASS']}" \
              "@#{ENV['TEST_MYSQL_HOST']}"
    @DB[:root] = Sequel.connect(command)

    # Create three databases on the server
    1.upto 3 do |i|
      # These two lines run the following raw SQL on the server
      @DB[:root].run("DROP DATABASE IF EXISTS db#{i}")
      @DB[:root].run("CREATE DATABASE IF NOT EXISTS db#{i};")
      @DB[:root].run("GRANT ALL PRIVILEGES ON db#{i}.*
                      TO '#{ENV['TEST_MYSQL_USER']}'@'%'
                      WITH GRANT OPTION;")

      # Connect to each database individually
      @DB[i] = Sequel.mysql("db#{i}", user: ENV['TEST_MYSQL_USER'],
                                      password: ENV['TEST_MYSQL_PASS'],
                                      host: ENV['TEST_MYSQL_HOST'])

      # Create i*i tables on each database
      (1..(i * i)).each do |j|
        @DB[i].create_table "table_#{j}" do
          primary_key :id
          String :name, null: false, unique: true
        end

        # Note: The table names for creating the dataset need to be symbols,
        # hence the .to_sym.
        dataset = @DB[i][:"table_#{j}"]
        # Insert i*i records in each of the i*i tables on each of the three
        # databases
        (1..(i * i)).each do |k|
          dataset.insert(name: "data-#{k}")
        end
      end
    end

    @expected = []
    # This query produces a set of hashes
    # { :'DB Name' => 'some name', :'Data Base Size in Bytes' => '#####'}
    # etc
    # @DB[1] because @DB[:root] has privileges greater than our test DB user,
    # so the we need to be consistent with the user we're running queries as.
    @DB[1].fetch("SELECT
                  table_schema
                    'DB Name',
                  cast(round(sum(data_length+index_length),1) as binary)
                    'Data Base Size in Bytes'
                  FROM information_schema.TABLES
                  GROUP BY table_schema") do |var|
      # @expected is populated like the hash is populated in
      # collectors.rb/collect_db.
      # It is later compared against the cache in the first test.
      @expected.push(var[:"DB Name"] => {
        :db_size => var[:"Data Base Size in Bytes"],
        :type => 'mysql',
        :active => 1,
        :server => ENV['TEST_MYSQL_HOST']}
        )
    end

    # Uncomment this line to see what the above query gets us
    # puts @expected
  end

  after :all do
    if  ENV['TEST_MYSQL_DB']
      # Drop all of the databases so our tests are idempotent
      [1, 2, 3].each do |n|
        @DB[:root].run("DROP DATABASE IF EXISTS db#{n}")
      end
    end
  end

  it '[mysql] collects the correct data and stores it in the right way.' do
    c = Collectors.new
    c.collect_db('mysql',
                 ENV['TEST_MYSQL_HOST'],
                 ENV['TEST_MYSQL_USER'],
                 ENV['TEST_MYSQL_PASSWORD'])

    # Reads values in from cache file
    cache = Cache.new("#{Iam.settings.cache_path}/db_cache")

    @expected.each do |var|
      expect(cache.dump).to include(var)
    end
  end

  it '[mysql] raises an error when it is unable to connect to the database.' do
    c = Collectors.new

    expect do
      c.collect_db('mysql', 'testing-mysql', 'someuser', 'badpass')
    end.to raise_error(Sequel::DatabaseConnectionError)
  end
end
