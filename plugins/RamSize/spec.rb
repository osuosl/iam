require_relative './plugin.rb'
describe 'RamSize plugin' do
  before(:all) do
    @db_table = Iam.DB[:ram_size_measurements]
  end

  # Store method
  describe '.store method' do
    before(:all) do
      RamSize.new.register
      @cache = Cache.new(ENV['CACHE_DIR'])
    end

    before(:each) do
      @cache.set('goodnode', ram_size: '512', active: true)
      @cache.set('badnode', ram_sizes: '[1024,256]', active: true)
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
      expect { RamSize.new.store('goodnode') }.to_not raise_error

      # Check that store actually stored the node
      expect { @db_table.where(node: 'goodnode').to exist }
    end

    it 'fails when not passed node name' do
      # This is bad plugin usage that should actually crash
      expect { RamSize.new.store }.to raise_error(ArgumentError)
    end

    it 'does not crash when passed improperly formatted data' do
      # Don't crash on bad info, but don't store anything either
      expect { RamSize.new.store('badnode') }.to_not raise_error
      expect { @db_table.where(node: 'badnode').to not_exist }

      # Store good info
      RamSize.new.store('goodnode')
      expect { @db_table.where(node: 'goodnode').to exist }
    end

    it 'properly sums all ram sizes when storing in DB' do
      # Store node data
      RamSize.new.store('goodnode')

      # Make sure store method properly summed ram sizes
      expect(@db_table.where(node: 'goodnode').get(:value)).to eq(30)
    end
  end
end
