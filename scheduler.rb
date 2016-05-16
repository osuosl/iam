require 'rufus/scheduler'
require 'redis'
require_relative 'collectors'
require_relative 'plugins/disk_sizes/plugin.rb'

redis = Redis.new(host: ENV['REDIS_HOST'])
s = Rufus::Scheduler.new

s.every '30m', first_in: 0.4 do
  # Collect ganeti node information every 30 minutes
  collector = Collectors.new
  collector.collect_ganeti
end

# Change '15m' on next line to 4 to test
s.every '30m', first_in: 4 do
  Iam.settings.DB[:plugins].get(:name).each do |plugin|
    puts plugin
    require_relative "plugins/#{plugin}/plugin.rb"
    redis.keys.each do |key|
      Object.const_get(plugin).store key unless key.end_with?(':datetime')
    end
  end
end


#  DiskSize.new.register
#  redis.keys.each do |key|
#    DiskSize.new.store key unless key.end_with?(':datetime')
#  end
#end

s.join
