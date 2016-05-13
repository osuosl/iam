require_relative './plugin.rb'
describe DiskSize do
  before(:all) do
    @redis = Redis.new(host: ENV['REDIS_HOST'])
  end

  it '.register does not raise an error when invoked' do
    expect { DiskSize.new.register }.to_not raise_error
  end

  it '.register actually actually creates a disk_size_measurements table' do
    # Table shouldn't exist before registration
    expect do
      Iam.settings.DB.table_exists?(:disk_size_measurements).to be_false
    end

    DiskSize.new.register

    # Table should exist after registration
    expect { Iam.settings.DB.table_exists?(:disk_size_measurements).to be_true }
  end

  # Store method
  it '.store does not fail with valid data' do
    # Put some data in redis for store method
    @redis.mset('nodename', JSON.generate(disk_sizes: '[10,20]', active: true),
                'nodename:datetime', DateTime.now)

    # Register DiskSize plugin
    DiskSize.new.register

    # Store redis nodes in DB, no error
    expect { DiskSize.new.store('nodename') }.to_not raise_error

    # Check that store actually stored the node
    expect do
      Iam.settings.DB[:disk_size_measurements].where(node: 'nodename').to exist
    end

    # Reset redis and DB
    @redis.del('nodename')
    @redis.del('nodename:datetime')
    Iam.settings.DB[:disk_size_measurements].where(
      node: %w(nodename nodename:datetime)).delete
  end

  it '.store fails when not passed node name' do
    # This is bad plugin usage that should actually crash
    expect { DiskSize.new.store }.to raise_error(ArgumentError)
  end

  it '.store does not crash when passed improperly formatted data' do
    # Put some data in redis for store method
    @redis.mset('badnode', JSON.generate(disk_size: '[10,20]', active: true),
                'goodnode', JSON.generate(disk_sizes: '[10,20]', active: true))

    # Register DiskSize plugin
    DiskSize.new.register

    # Don't crash on bad info, but don't store anything either
    expect { DiskSize.new.store('badnode') }.to_not raise_error
    dataset = Iam.settings.DB[:disk_size_measurements]
    expect { dataset.where(node: 'badnode').to not_exist }

    # Store good info
    DiskSize.new.store('goodnode')
    expect { dataset.where(node: 'goodnode').to exist }

    # Reset redis and DB
    @redis.del('badnode')
    @redis.del('goodnode')
    Iam.settings.DB[:disk_size_measurements].where(
      node: %w(badnode goodnode)).delete
  end

  it '.store properly sums all disk sizes when storing in DB' do
    # Put some data in redis for store method
    @redis.mset('nodename', JSON.generate(disk_sizes: '[10,20]', active: true),
                'nodename:datetime', DateTime.now)

    # Register DiskSize plugin
    DiskSize.new.register

    # Store node data
    dataset = Iam.settings.DB[:disk_size_measurements]
    DiskSize.new.store('nodename')

    # Make sure store method properly summed disk sizes
    expect(dataset.where(node: 'nodename').get(:value)).to eq(30)

    # Reset redis and DB
    @redis.del('nodename')
    @redis.del('nodename:datetime')
    Iam.settings.DB[:disk_size_measurements].where(
      node: %w(nodename nodename:datetime)).delete
  end

  # Report method
  describe '.report method' do
    before do
      DiskSize.new.register
      @db_table = Iam.DB[:disk_size_measurements]
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

    after do
      @db_table.where(node: 'TEST_NODE').delete
    end
  end
end
