require_relative './plugin.rb'
describe 'VCPUCount plugin' do
  before(:all) do
    @db_table = Iam.settings.DB[:vcpu_count_measurements]
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
end
