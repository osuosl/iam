# frozen_string_literal: true
require_relative './plugin.rb'
describe 'RamSize plugin' do
  before(:all) do
    @db_table = Iam.DB[:ram_size_measurements]
  end

  # Store method
  describe '.store method' do
    before(:all) do
      RamSize.new.register
      @cache = Cache.new("#{Iam.settings.cache_path}/node_cache")
    end

    before(:each) do
      @cache.set('goodnode', total_ram: '512', active: true)
      @cache.set('badnode', total_ram: '[1024,256]', active: true)
      @cache.write
    end

    after(:each) do
      @cache.del('goodnode')
      @cache.del('badnode')
      @cache.write
      @db_table.where(node: %w(badnode goodnode)).delete
    end

    it 'does not fail with valid data' do
      # Everything works as expected
      expect { RamSize.new.store('goodnode') }.to_not raise_error
      expect(@db_table.where(node: 'goodnode').get(:value)).to eq(512)
    end

    it 'fails when not passed node name' do
      # This is bad plugin usage that should actually crash
      expect { RamSize.new.store }.to raise_error(ArgumentError)
    end

    it 'does not crash when passed improperly formatted data' do
      # Don't crash on bad info, but don't store anything either
      expect { RamSize.new.store('badnode') }.to_not raise_error
      expect(@db_table.where(node: 'badnode').all).to be_empty

      # Store good info
      RamSize.new.store('goodnode')
      expect(@db_table.where(node: 'goodnode').all).to_not be_nil
    end
  end
end
