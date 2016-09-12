require_relative './plugin.rb'
describe 'BasePlugin plugin' do
  before(:all) do
    @db_table = Iam.settings.DB[:test_plugin_measurements]
  end

  # Register method
  describe '.register method' do
    it 'does not raise an error when invoked' do
      expect { TestingPlugin.new.register }.to_not raise_error
    end

    it 'creates a test_plugin_measurements table' do
      # Table shouldn't exist before registration
      expect(Iam.settings.DB.table_exists?(
               :test_plugin_measurements
      )).to be false

      TestingPlugin.new.register

      # Table should exist after registration
      expect(Iam.settings.DB.table_exists?(
               :test_plugin_measurements
      )).to be true
    end
  end

  # Report method
  describe '.report method' do
    before(:all) do
      TestingPlugin.new # Make sure initialize is called

      DAYS = 60 * 60 * 24
      ONE_DAY_AGO = (Time.now - 1 * DAYS).round(0)
      TWENTY_NINE_DAYS_AGO = (Time.now - 29 * DAYS).round(0)
      THIRTY_ONE_DAYS_AGO  = (Time.now - 31 * DAYS).round(0)

      good_1  = { created: ONE_DAY_AGO, resource: 'good_1', value: 1 }
      good_29 = { created: TWENTY_NINE_DAYS_AGO,
                  resource: 'good_29',
                  value: 29 }
      good_31 = { created: THIRTY_ONE_DAYS_AGO, resource: 'good_31', value: 31 }

      @db_table.insert(good_1)
      @db_table.insert(good_29)
      @db_table.insert(good_31)
    end

    after(:all) do
      @db_table.where(resource: 'good1').delete
      @db_table.where(resource: 'good29').delete
      @db_table.where(resource: 'good31').delete
    end

    it 'should return data on all resources for the last 30 days by default' do
      expect(TestingPlugin.new.report).to\
        eq([{ id: 1, created: ONE_DAY_AGO, resource: 'good_1', value: 1 },
            { id: 2, created: TWENTY_NINE_DAYS_AGO, resource: 'good_29',
              value: 29 }])
    end

    it 'returns data on a known specific resources' do
      expect(TestingPlugin.new.report(resource: 'good_29')).to\
        eq([{ id: 2, created: TWENTY_NINE_DAYS_AGO, resource: 'good_29',
              value: 29 }])
    end

    it 'does not return data on known specific resource out of date range' do
      expect(TestingPlugin.new.report(resource: 'good_31')).to eq([])
    end

    it 'does return data on known specific resource with custom date range' do
      expect(TestingPlugin.new.report({ resource: 'good_31' },
                                      THIRTY_ONE_DAYS_AGO - 1 * DAYS,
                                      THIRTY_ONE_DAYS_AGO)).to\
                                        eq([{ id: 3,
                                              created: THIRTY_ONE_DAYS_AGO,
                                              resource: 'good_31',
                                              value: 31 }])
    end

    it 'returns empty on unknown resource' do
      expect(TestingPlugin.new.report(resource: 'bad_1')).to eq([])
    end

    it 'returns TypeError on invalid day input' do
      expect do
        TestingPlugin.new.report({ resource: 'good_1' }, '1', '2')
      end.to \
        raise_error(TypeError)
    end

    it 'returns ArgumentError on inverted date range' do
      expect do
        TestingPlugin.new.report({ resource: 'good_1' },
                                 ONE_DAY_AGO,
                                 TWENTY_NINE_DAYS_AGO)
      end.to \
        raise_error(ArgumentError)
    end
  end
end
