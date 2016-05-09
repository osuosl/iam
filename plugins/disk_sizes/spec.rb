require_relative './plugin.rb'
describe DiskSize do
  it '.register does not raise an error when invoked' do
    expect { DiskSize.new.register }.to_not raise_error
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

  it '.report' do
  end
end
