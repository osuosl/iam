require 'rufus/scheduler'
require 'redis'
require_relative 'collectors'
require_relative 'plugins/DiskSize/plugin.rb'

s = Rufus::Scheduler.new

s.every '30m', first_in: 0.4 do
  # Collect ganeti node information every 30 minutes
  collector = Collectors.new
  collector.collect_ganeti
end

# Change '15m' on next line to 4 to test
s.every '30m', first_in: 4 do
  redis = Redis.new(host: ENV['REDIS_HOST'])
  DiskSize.new.register
  redis.keys.each do |key|
    DiskSize.new.store key unless key.end_with?(':datetime')
  end
  puts 'done'
end

s.join
