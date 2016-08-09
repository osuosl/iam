require_relative './plugin.rb'
describe 'DBSize plugin' do
  before(:all) do
    @db_table = Iam.DB[:db_size_measurements]
    db_key = 'Data Base Size in Bytes'
  end

  # Store method
  describe '.store method' do
    before(:all) do
      DBSize.new.register
      @cache = Cache.new(ENV['CACHE_DIR'])
    end

    before(:each) do
      @cache.set('test_db', db_key: "123456.0", active: true)
      @cache.write
    end

    after(:each) do
      @cache.del('test_db')
      @cache.write
      @db_table.where(node: %w(test_db test_db2)).delete
    end

    it 'does not fail with valid data' do
      # Store cached nodes in DB, no error
      expect { DBSize.new.store('test_db') }.to_not raise_error

      # Check that store actually stored the node
      expect(@db_table.where(node: 'test_dbw')).to_not be_empty
    end

    it 'fails when not passed node name' do
      # This is bad plugin usage that should actually crash
      expect { DBSize.new.store }.to raise_error(ArgumentError)
    end
    
  end
end
