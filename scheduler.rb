require 'rufus/scheduler'
require_relative 'collectors'

s = Rufus::Scheduler.new

p [ :scheduled_at, Time.now ]

s.every '30m', :first_in => 0.4 do
    collector = Collectors.new
    collector.collect_ganeti
    p [ :success,  Time.now ]
end

s.join
