require_relative './plugin.rb'
describe 'DiskTemplate plugin' do
  before(:all) do
    @db_table = Iam.settings.DB[:disk_template_measurements]
  end

  # Register method
  describe '.register method' do
    it 'does not raise an error when invoked' do
      expect { DiskTemplate.new.register }.to_not raise_error
    end

    it 'creates a disk_template_measurements table' do
      # Table shouldn't exist before registration
      expect do
        Iam.settings.DB.table_exists?(:disk_template_measurements).to be_false
      end

      DiskTemplate.new.register

      # Table should exist after registration
      expect do
        Iam.settings.DB.table_exists?(:disk_template_measurements).to be_true
      end
    end
  end

  # Store method
  describe '.store method' do
    before(:all) do
      @redis = Redis.new(host: ENV['REDIS_HOST'])
    end

    before(:each) do
      @redis.mset('goodnode', JSON.generate(disk_template: 'drbd', active: true),
                  'badnode', JSON.generate(disk_type: '1', active: true))
    end

    after(:each) do
      @redis.del('goodnode')
      @redis.del('badnode')
      @db_table.where(node: %w(badnode goodnode)).delete
    end

    it 'does not fail with valid data' do
      # Store redis nodes in DB, no error
      expect { DiskTemplate.new.store('goodnode') }.to_not raise_error

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
      expect { @db_table.where(node: 'badnode').to not_exist }

      # Store good info
      DiskTemplate.new.store('goodnode')
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

  # Report method
  describe '.report method' do
    before(:all) do
      DiskTemplate.new # Make sure initialize is called

      DAYS = 60 * 60 * 24
      ONE_DAY_AGO = (Time.now-1*DAYS).round(0)
      TWENTY_NINE_DAYS_AGO = (Time.now-29*DAYS).round(0)
      THIRTY_ONE_DAYS_AGO  = (Time.now-31*DAYS).round(0)

      good_1  = {created: ONE_DAY_AGO, node: 'good_1' , value: 'drbd' }
      good_29 = {created: TWENTY_NINE_DAYS_AGO, node: 'good_29', value: 'other'}
      good_31 = {created: THIRTY_ONE_DAYS_AGO , node: 'good_31', value: 'drbd'}

      @db_table.insert(good_1)
      @db_table.insert(good_29)
      @db_table.insert(good_31)
    end

    after(:all) do
      @db_table.where(node: 'good1' ).delete
      @db_table.where(node: 'good29').delete
      @db_table.where(node: 'good31').delete
    end

    it 'should return data on all nodes for the last 30 days by default' do
      expect(DiskTemplate.new.report).to\
        eq([{:id=>1, :node_resource=>nil, :created=>ONE_DAY_AGO,
             :node=>"good_1", :value=>'drbd', :active=>nil},
            {:id=>2, :node_resource=>nil, :created=>TWENTY_NINE_DAYS_AGO,
             :node=>"good_29", :value=>'other', :active=>nil}])
    end

    it 'returns data on a known specific nodes' do
      expect(DiskTemplate.new.report('good_29')).to\
        eq([{:id=>2, :node_resource=>nil, :created=>TWENTY_NINE_DAYS_AGO,
             :node=>"good_29", :value=>'other', :active=>nil}])
    end

    it 'does not return data on know specific node out of date range' do
      expect(DiskTemplate.new.report('good_31')).to eq([])
    end

    it 'does return data on know specific node with custom date range' do
      expect(DiskTemplate.new.report('good_31', THIRTY_ONE_DAYS_AGO - 1 * DAYS,
                                  THIRTY_ONE_DAYS_AGO)).to\
        eq([{:id=>3, :node_resource=>nil, :created=>THIRTY_ONE_DAYS_AGO,
             :node=>"good_31", :value=>'drbd', :active=>nil}])
    end

    it 'returns empty on unknown node' do
      expect(DiskTemplate.new.report('bad_1')).to eq([])
    end

    it 'returns TypeError on invalid day input' do
      expect { DiskTemplate.new.report('good_1', start_date='1',
                                    end_date='2') }.to \
        raise_error(TypeError)
    end

    it 'returns ArgumentError on inverted date range' do
      expect { DiskTemplate.new.report('good_1', start_date=ONE_DAY_AGO,
                                    end_date=TWENTY_NINE_DAYS_AGO) }.to \
        raise_error(ArgumentError)
    end
  end
end
