# frozen_string_literal: true
require_relative '../../collectors.rb'
require_relative '../spec_helper.rb'
require 'chef_zero/server'

describe 'IaM Chef Collector' do
  include Rack::Test::Methods
  # Create new chef server in memory
  server = ChefZero::Server.new

  before :all do
    # Start the chef server
    server.start_background

    # Define test data
    # This set of nested hashes is formatted specifically for chef-zero to
    # reflect the data returned by a query to the /node endpoint
    test_data = {
      'nodes' => {
        'testNode1' => {
          'name' => 'testNode1',
          'automatic' => {
            'cpu' => {
              'total' => '2',
              'real' => '1'
            },
            'memory' => {
              'total' => '501924kB',
              'free' => '196504kB'
            }
          }
        }
      }
    }

    @expected = []
    # Populate the expected array the same way as the collector
    # The actual return data will be in JSON format, so the
    # access will be slightly different
    test_data['nodes'].each do |_key, val|
      @expected.push(
        val['name'] => {
          'ram_total' => val['automatic']['memory']['total'],
          'ram_free' => val['automatic']['memory']['free'],
          'cpus_total' => val['automatic']['cpu']['total'],
          'cpus_real' => val['automatic']['cpu']['real']
        }
      )
    end

    # Load data onto test server
    server.load_data(test_data)
  end

  after :all do
    # Clear server data
    server.clear_data
    # Stop the chef server
    server.stop
  end

  it 'Correctly reads and stores data' do
    c = Collectors.new
    # call chef collector

    # Chef zero is running in no-auth mode,
    # so it only needs to be provided with valid
    # input in order to respond to REST requests

    # The private key will need to be added to the
    # project files and linked in environment variables
    # For the purposes of testing, this key is arbitrary
    # In the live collector, a chef user's private key will
    # need to be passed in
    c.collect_chef(
      server.url,          # The url of the server to collect from
      'test',              # an arbitrary user name
      # path to a properly formatted private key
      File.expand_path('../chef_test.pem', __FILE__)
    )
    cache = Cache.new("#{Iam.settings.cache_path}/chef_cache")

    @expected.each do |var|
      expect(cache.dump).to include(var)
    end
  end
end
