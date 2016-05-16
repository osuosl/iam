require_relative './plugin.rb'
describe 'VCPUCount plugin' do
  before(:all) do
    @db_table = Iam.DB[:vcpu_count_measurements]
  end

  # Register method
  describe '.register method' do
    it 'does not raise an error when invoked' do
      expect { VCPUCount.new.register }.to_not raise_error
    end

    it 'creates a vcpu_count_measurements table' do
      # Table shouldn't exist before registration
      expect do
        Iam.settings.DB.table_exists?(:vcpu_count_measurements).to be_false
      end

      VCPUCount.new.register

      # Table should exist after registration
      expect do
        Iam.settings.DB.table_exists?(:vcpu_count_measurements).to be_true
      end
    end
  end

  # Store method
  describe '.store method' do
    before(:all) do
      @redis = Redis.new(host: ENV['REDIS_HOST'])
    end

    before(:each) do
      @redis.mset('goodnode', JSON.generate(num_cpus: '8', active: true),
                  'badnode', JSON.generate(num_cpu: 'eight', active: true))
    end

    after(:each) do
      @redis.del('goodnode')
      @redis.del('badnode')
      @db_table.where(node: %w(badnode goodnode)).delete
    end

    it 'does not fail with valid data' do
      # Store redis nodes in DB, no error
      expect { VCPUCount.new.store('goodnode') }.to_not raise_error

      # Check that store actually stored the node
      expect { @db_table.where(node: 'goodnode').to exist }
    end

    it 'fails when not passed node name' do
      # This is bad plugin usage that should actually crash
      expect { VCPUCount.new.store }.to raise_error(ArgumentError)
    end

    it 'does not crash when passed improperly formatted data' do
      # Don't crash on bad info, but don't store anything either
      expect { VCPUCount.new.store('badnode') }.to_not raise_error
      expect { @db_table.where(node: 'badnode').to not_exist }

      # Store good info
      VCPUCount.new.store('goodnode')
      expect { @db_table.where(node: 'goodnode').to exist }
    end

    it 'stores the right thing in the value field' do
      # Store node data
      VCPUCount.new.store('goodnode')

      # Make sure store method properly stored integer representation of
      # num_cpus
      expect(@db_table.where(node: 'goodnode').get(:value)).to eq(8)
    end
  end

  # Report method
  describe '.report method' do
    before(:all) do
      @db_table.insert(created: Time.now,
                       node:    'goodnode',
                       value:   8)
    end

    after(:all) do
      @db_table.where(node: 'goodnode').delete
    end

    it 'should return data on all nodes for the last day by default' do
      result = VCPUCount.new.report
      expect { result.should include(node: 'goodnode') }
    end

    it 'returns data on a known specific nodes for 1 day' do
      result = VCPUCount.new.report('goodnode', 1)
      expect { result.should include(node: 'goodnode') }
      expect { result.should include(value: 8) }
    end

    it 'returns empty on unknown node' do
      result = VCPUCount.new.report('8', 1)
      expect { result.to be_empty }
    end

    it 'should return TypeError on invalid day input' do
      expect { VCPUCount.new.report('*', 'one') }.to raise_error(TypeError)
    end
  end
end
