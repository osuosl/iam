require_relative './plugin.rb'
describe 'DiskSize plugin' do
  before(:all) do
    @db_table = Iam.DB[:disk_size_measurements]
  end

  # Register method
  describe '.register method' do
    it 'does not raise an error when invoked' do
      expect { DiskSize.new.register }.to_not raise_error
    end

    it 'creates a disk_size_measurements table' do
      # Table shouldn't exist before registration
      expect do
        Iam.settings.DB.table_exists?(:disk_size_measurements).to be_false
      end

      DiskSize.new.register

      # Table should exist after registration
      expect do
        Iam.settings.DB.table_exists?(:disk_size_measurements).to be_true
      end
    end
  end

  # Store method
  describe '.store method' do
    before(:all) do
      DiskSize.new.register
      @redis = Redis.new(host: ENV['REDIS_HOST'])
    end

    before(:each) do
      @redis.mset(
        'goodnode', JSON.generate(disk_sizes: '[10,20]', active: true),
        'badnode', JSON.generate(disk_size: '[10,20]', active: true))
    end

    after(:each) do
      @redis.del('goodnode')
      @redis.del('badnode')
      @db_table.where(node: %w(badnode goodnode)).delete
    end

    it 'does not fail with valid data' do
      # Store redis nodes in DB, no error
      expect { DiskSize.new.store('goodnode') }.to_not raise_error

      # Check that store actually stored the node
      expect { @db_table.where(node: 'goodnode').to exist }
    end

    it 'fails when not passed node name' do
      # This is bad plugin usage that should actually crash
      expect { DiskSize.new.store }.to raise_error(ArgumentError)
    end

    it 'does not crash when passed improperly formatted data' do
      # Don't crash on bad info, but don't store anything either
      expect { DiskSize.new.store('badnode') }.to_not raise_error
      expect { @db_table.where(node: 'badnode').to not_exist }

      # Store good info
      DiskSize.new.store('goodnode')
      expect { @db_table.where(node: 'goodnode').to exist }
    end

    it 'properly sums all disk sizes when storing in DB' do
      # Store node data
      DiskSize.new.store('goodnode')

      # Make sure store method properly summed disk sizes
      expect(@db_table.where(node: 'goodnode').get(:value)).to eq(30)
    end
  end

  # Report method
  describe '.report method' do
    before(:all) do
      DiskSize.new.register
      @db_table.insert(created: Time.now,
                       node: 'TEST_NODE',
                       value: 1_234_567_890)
    end
    it 'should return data on all nodes for the last day by default' do
      result = DiskSize.new.report
      expect { result.should include(node: 'TEST_NODE') }
    end

    it 'returns data on a known specific nodes for 1 day' do
      result = DiskSize.new.report('TEST_NODE', 1)
      expect { result.should include(node: 'TEST_NODE') }
    end

    it 'returns empty on unknown node' do
      result = DiskSize.new.report('1_234_567_890', 1)
      expect { result.to be_empty }
    end

    it 'should return empty on invalid day input' do
      result = DiskSize.new.report('*', 'one')
      expect { result.to be_empty }
    end

    it 'should return empty on invalid fqdn input' do
      result = DiskSize.new.report(1_234_567_890, 'one')
      expect { result.to be_empty }
    end

    after(:all) do
      @db_table.where(node: 'TEST_NODE').delete
    end
  end
end
