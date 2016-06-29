require_relative './plugin.rb'
describe 'DiskTemplate plugin' do
  before(:all) do
    @db_table = Iam.settings.DB[:disk_template_measurements]
  end

  # Store method
  describe '.store method' do
    before(:all) do
      @cache = Cache.new(ENV['CACHE_FILE'])
    end

    before(:each) do
      @cache.set('goodnode', disk_template: 'drbd', active: true)
      @cache.set('badnode', disk_type: '1', active: true)
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
      expect { DiskTemplate.new.store('goodnode') }.to_not raise_error

### This bit arbitrarily passes ###
      # Check that store actually stored the node
      expect { @db_table.where(node: 'goodnode').to exist }
    end

    it 'fails when not passed node name' do
      # This is bad plugin usage that should actually crash
      expect { DiskTemplate.new.store }.to raise_error(ArgumentError)
    end

    it 'does not crash when passed improperly formatted data' do
      # Don't crash on bad info, but don't store anything either
      expect { DiskTemplate.new.store('badnode') }.to_not raise_error
### Doesn't actually check for anything! i.e. not_exist -> exist = still passes
      expect { @db_table.where(node: 'badnode').to not_exist }

      # Store good info
      DiskTemplate.new.store('goodnode')
### Same thing here -- doesn't actually check for object existence
      expect { @db_table.where(node: 'goodnode').to exist }
    end

    it 'stores the right thing in the value field' do
      # Store node data
      DiskTemplate.new.store('goodnode')

      # Make sure store method properly stored integer representation of
      # num_cpus
      expect(@db_table.where(node: 'goodnode').get(:value)).to eq('drbd')
    end
  end
end
