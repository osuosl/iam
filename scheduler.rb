require 'rufus/scheduler'
require 'redis'
require_relative 'collectors'
require_relative 'environment'

redis = Redis.new(host: ENV['REDIS_HOST'])
s = Rufus::Scheduler.new

s.every '30m', first_in: 0.4 do
  # Collect ganeti node information every 30 minutes
  collector = Collectors.new
  collector.collect_ganeti
end

# Change '15m' on next line to 4 to test
s.every '30m', first_in: '15m' do
  # For each entry in the plugins table
  Iam.settings.DB[:plugins].each do |p|
    # Require the plugin based on the name in the table
    require_relative "plugins/#{p[:name]}/plugin.rb"
    # For each key in redis
    redis.keys.each do |key|
      # Store the node information in the proper table with the plugin's store
      # method. The plugin object is retrieved from the name string using
      # Object.const_get. Do not try to store keys that store a datetime object.
      Object.const_get(p[:name]).new.store key unless key.end_with?('datetime')
    end
  end
end

s.join
