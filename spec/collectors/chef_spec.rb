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
            },
            'filesystem2' => {
              'by_device' => {
                '/dev/vda3' => {
                  'kb_size' => '2',
                  'kb_used' => '1',
                  'fs_type' => 'ext4'
                },
                '/dev/vda1' => {
                  'kb_size' => '4',
                  'kb_used' => '3',
                  'fs_type' => 'ext4'
                }
              }
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
          'cpus_real' => val['automatic']['cpu']['real'],
          'disk_size' => '6',
          'disk_usage' => '4',
          'disk_count' => '2'
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
    # Chef zero is running in no-auth mode,
    # so it only needs to be provided with valid
    # input in order to respond to REST requests

    # For the purposes of testing, this key is arbitrary so long as
    # it's properly formatted
    # In the live collector, a chef user's private key will
    # need to be passed in
    c.collect_chef(
      server.url,
      ENV['CHEF_CLIENT'],
      ENV['CHEF_KEY']
    )
    cache = Cache.new("#{Iam.settings.cache_path}/chef_cache")

    @expected.each do |var|
      expect(cache.dump).to include(var)
    end
  end
end
