require 'rufus/scheduler'
require_relative 'collectors.rb'
require_relative 'environment.rb'
require_relative 'lib/cache.rb'

cache = Cache.new(ENV['CACHE_FILE'])
s = Rufus::Scheduler.new

s.every '30m', first_in: 0.4 do
  # Collect ganeti node information every 30 minutes
  collector = Collectors.new
  collector.collect_ganeti
end

# Change '15m' on next line to 4 to test
s.every '30m', first_in: '15m' do
  `rake plugins`
  # For each entry in the plugins table
  Iam.settings.DB[:plugins].each do |p|
    # Require the plugin based on the name in the table
    require_relative "plugins/#{p[:name]}/plugin.rb"
    # For each key in cache
    cache.keys.each do |key|
      # Store the node information in the proper table with the plugin's store
      # method. The plugin object is retrieved from the name string using
      # Object.const_get. Do not try to store keys that store a datetime object.
      Object.const_get(p[:name]).new.store key unless key.end_with?('datetime')
    end
  end
end

s.join
