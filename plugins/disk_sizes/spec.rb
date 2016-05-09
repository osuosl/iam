require_relative './plugin.rb'
describe DiskSize do
  it '.register does not raise an error when invoked' do
    expect { DiskSize.new.register }.to_not raise_error
  end

  it '.register actually actually creates a disk_size_measurements table' do
    expect{ Iam.settings.DB.table_exists?(:disk_size_measurements).to be_false }
    DiskSize.new.register
    expect{ Iam.settings.DB.table_exists?(:disk_size_measurements).to be_true }
  end

  it '.store does not fail with valid data' do
    redis = Redis.new(:host => ENV['REDIS_HOST'])
    redis.mset('nodename', JSON.generate({disk_sizes: '[10,20]', active: true}),
               'nodename:datetime', DateTime.now)
    DiskSize.new.register
    expect{ DiskSize.new.store('nodename') }.to_not raise_error
    expect{ Iam.settings.DB[:disk_size_measurements].where(node: 'nodename').to exist }
  end

  it '.store fails when not passed node name' do
    expect{ DiskSize.new.store() }.to raise_error(ArgumentError)
  end

  it '.store does not crash when passed improperly formatted data' do
    redis = Redis.new(:host => ENV['REDIS_HOST'])
    redis.mset('badnode', JSON.generate({disk_size: '[10,20]', active: true}),
               'goodnode', JSON.generate({disk_sizes: '[10,20]', active: true}))
    DiskSize.new.register
    expect{ DiskSize.new.store('badnode') }.to_not raise_error
    expect{ Iam.settings.DB[:disk_size_measurements].where('node'=>'badnode').to not_exist }

    DiskSize.new.store('goodnode')
    expect{ Iam.settings.DB[:disk_size_measurements].where('node'=>'goodnode').to exist }
  end

  it '.store properly sums all disk sizes when storing in DB' do
    redis = Redis.new(:host => ENV['REDIS_HOST'])
    redis.mset('nodename', JSON.generate({disk_sizes: '[10,20]', active: true}),
               'nodename:datetime', DateTime.now)
    DiskSize.new.register
    DiskSize.new.store('nodename')
    expect(Iam.settings.DB[:disk_size_measurements].where(:node=>'nodename').get(:value)).to equal(30)
  end

  it '.report' do
  end
end
