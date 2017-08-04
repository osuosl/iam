# frozen_string_literal: true
require_relative './plugin.rb'
describe 'NodeActive plugin' do
  before(:all) do
    @db_table = Iam.DB[:node_active_measurements]
  end

  # Store method
  describe '.store method' do
    before(:all) do
      NodeActive.new.register
      @cache = Cache.new("#{Iam.settings.cache_path}/node_cache")
    end

    before(:each) do
      @cache.set('upnode', active: true)
      @cache.set('downnode', active: false)
      @cache.set('badnode', fred: true)
      @cache.write
    end

    after(:each) do
      @cache.del('upnode')
      @cache.del('downnode')
      @cache.del('badnode')
      @cache.write
      @db_table.where(node: %w(downnode upnode badnode)).delete
    end

    it 'does not fail with valid up node data' do
      # Store cached nodes in DB, no error
      expect { NodeActive.new.store('upnode') }.to_not raise_error

      # Check that store actually stored the node
      expect(@db_table.where(node: 'upnode')).to_not be_empty
    end

    it 'does not fail with valid down node data' do
      # Store cached nodes in DB, no error
      expect { NodeActive.new.store('downnode') }.to_not raise_error

      # Check that store actually stored the node
      expect(@db_table.where(node: 'downnode')).to_not be_empty
    end

    it 'fails when not passed node name' do
      # This is bad plugin usage that should actually crash
      expect { NodeActive.new.store }.to raise_error(ArgumentError)
    end

    it 'does not crash when passed improperly formatted data' do
      # Don't crash on bad info, but don't store anything either
      expect { NodeActive.new.store('badnode') }.to_not raise_error
      expect(@db_table.where(node: 'badnode')).to be_empty

      # Store good info
      NodeActive.new.store('upnode')
      expect(@db_table.where(node: 'upnode')).to_not be_empty
    end

    it 'stores the right thing in the value field' do
      # Store node data
      NodeActive.new.store('upnode')
      NodeActive.new.store('downnode')

      # Make sure store method properly stored true/false values of nodes
      expect(@db_table.where(node: 'upnode').get(:value)).to eq(true)
      expect(@db_table.where(node: 'downnode').get(:value)).to eq(false)
    end
  end
end
