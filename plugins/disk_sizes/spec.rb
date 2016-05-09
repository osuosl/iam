require_relative './plugin.rb'
describe DiskSize do
  it '.register' do
  end
  it '.store should not fail with valid data' do
    redis = Redis.new(:host => ENV['REDIS_HOST'])
    redis.mset('nodename', JSON.generate({disk_sizes: '[10,20]', active: true}),
               'nodename:datetime', DateTime.now)
    DiskSize.new.register
    expect{ DiskSize.new.store('nodename') }.to_not raise_error
    expect{ Iam.settings.DB[:disk_size_measurements].where(node: 'nodename').to exist }
  end
  it '.store should fail when not passed node name' do
    expect{ DiskSize.new.store() }.to raise_error(ArgumentError)
  end
  it '.report' do
  end
end
