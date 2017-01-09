require_relative './plugin.rb'
describe 'DBSize plugin' do
  before(:all) do
    @db_table = Iam.DB[:db_size_measurements]
  end

  # Store method
  describe '.store method' do
    before(:all) do
      DBSize.new.register
      @cache = Cache.new("#{Iam.settings.cache_path}/db_cache")
    end

    before(:each) do
      # Store cached nodes in DB, no error
      @cache.set('test_db', db_size: 123_456.0, active: true)
      @cache.write
    end

    after(:each) do
      @cache.del('test_db')
      @cache.write
      @db_table.where(db: %w(test_db test_db2)).delete
    end

    it 'does not fail with valid data' do
      # Store cached nodes in DB, no error
      expect { DBSize.new.store('test_db') }.to_not raise_error
      # Check that store actually stored the node
      expect(@db_table.where(db: 'test_db')).to_not be_empty
    end

    it 'does fail with invalid data' do
      @cache.set('bad_test_db', db_size: 'ABCD')
      @cache.write

      expect { DBSize.new.store('bad_test_db') }.to \
        output(/malformed/).to_stderr_from_any_process

      @cache.del('bad_test_db')
      @cache.write
    end

    it 'fails when not passed db name' do
      # This is bad plugin usage that should actually crash
      expect { DBSize.new.store }.to raise_error(ArgumentError)
    end
  end
end
