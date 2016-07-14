require_relative './plugin.rb'
describe 'DiskSize plugin' do
  before(:all) do
    @db_table = Iam.DB[:disk_size_measurements]
  end

  # Store method
  describe '.store method' do
    before(:all) do
      DiskSize.new.register
      @cache = Cache.new(ENV['CACHE_DIR'])
    end

    before(:each) do
      @cache.set('goodnode', disk_sizes: '[10, 20]', active: true)
      @cache.set('badnode', disk_size: '[10, 20]', active: true)
      @cache.write
    end

    after(:each) do
      @cache.del('goodnode')
      @cache.del('badnode')
      @cache.write
      @db_table.where(node: %w(badnode goodnode)).delete
    end

    it 'does not fail with valid data' do
      # Store cached nodes in DB, no error
      expect { DiskSize.new.store('goodnode') }.to_not raise_error

      # Check that store actually stored the node
      expect(@db_table.where(node: 'goodnode')).to_not be_empty
    end

    it 'fails when not passed node name' do
      # This is bad plugin usage that should actually crash
      expect { DiskSize.new.store }.to raise_error(ArgumentError)
    end

    it 'does not crash when passed improperly formatted data' do
      # Don't crash on bad info, but don't store anything either
      expect { DiskSize.new.store('badnode') }.to_not raise_error
      expect(@db_table.where(node: 'badnode')).to be_empty

      # Store good info
      DiskSize.new.store('goodnode')
      expect(@db_table.where(node: 'goodnode')).to_not be_empty
    end

    it 'properly stores all disk sizes when storing in DB' do
      # Store node data
      DiskSize.new.store('goodnode')

      # Make sure store method properly summed disk sizes
      expect(@db_table.where(node: 'goodnode').get(:disk_count)).to eq(2)
      expect(@db_table.where(node: 'goodnode').get(:disk1_size)).to eq(10)
      expect(@db_table.where(node: 'goodnode').get(:disk2_size)).to eq(20)
    end
  end
end
