require 'rufus/scheduler'
require_relative 'collectors'

s = Rufus::Scheduler.new

s.every '30m', :first_in => 0.4 do
  # Collect ganeti node information every 30 minutes
  collector = Collectors.new
  collector.collect_ganeti
end

s.join
