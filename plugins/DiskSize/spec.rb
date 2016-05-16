require_relative './plugin.rb'
describe DiskSize do
  # register method
  it '.register does not raise an error when invoked' do
    expect { DiskSize.new.register }.to_not raise_error
  end

  it '.register actually actually creates a disk_size_measurements table' do
    expect do
      Iam.settings.DB.table_exists?(:disk_size_measurements).to be_false
    end
    DiskSize.new.register
    expect { Iam.settings.DB.table_exists?(:disk_size_measurements).to be_true }
  end

  # Store method
  it '.store does not fail with valid data' do
    redis = Redis.new(host: ENV['REDIS_HOST'])
    redis.mset('nodename', JSON.generate(disk_sizes: '[10,20]', active: true),
               'nodename:datetime', DateTime.now)
    DiskSize.new.register
    expect { DiskSize.new.store('nodename') }.to_not raise_error
    expect do
      Iam.settings.DB[:disk_size_measurements].where(node: 'nodename').to exist
    end
    redis.del('nodename')
    redis.del('nodename:datetime')
  end

  it '.store fails when not passed node name' do
    expect { DiskSize.new.store }.to raise_error(ArgumentError)
  end

  it '.store does not crash when passed improperly formatted data' do
    redis = Redis.new(host: ENV['REDIS_HOST'])
    redis.mset('badnode', JSON.generate(disk_size: '[10,20]', active: true),
               'goodnode', JSON.generate(disk_sizes: '[10,20]', active: true))
    DiskSize.new.register
    expect { DiskSize.new.store('badnode') }.to_not raise_error
    dataset = Iam.settings.DB[:disk_size_measurements]
    expect { dataset.where(node: 'badnode').to not_exist }

    DiskSize.new.store('goodnode')
    expect { dataset.where(node: 'goodnode').to exist }
    redis.del('badnode')
    redis.del('goodnode')
  end

  it '.store properly sums all disk sizes when storing in DB' do
    redis = Redis.new(host: ENV['REDIS_HOST'])
    redis.mset('nodename', JSON.generate(disk_sizes: '[10,20]', active: true),
               'nodename:datetime', DateTime.now)
    DiskSize.new.register
    dataset = Iam.settings.DB[:disk_size_measurements]
    DiskSize.new.store('nodename')
    expect(dataset.where(node: 'nodename').get(:value)).to eq(30)
    redis.del('nodename')
    redis.del('nodename:datetime')
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
