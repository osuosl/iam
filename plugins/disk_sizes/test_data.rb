# DB FILLING SCRIPT
#
#

# ENV VARS
require_relative '../../environment.rb'

# DB CONNECT
DB_Table = Iam.DB[:disk_size_measurements]

# BEFORE
puts
puts 'Before:'
puts DB_Table.all
puts '^BEFORE^^BEFORE^BEFORE^BEFORE^BEFORE^BEFORE^BEFORE^BEFORE'
puts

# MR.LOOPY LOOPHOLE
(0..20).each do |i|
  time_data = Time.now
  node_data = 'FACEYMYBOOKY.com' + i.to_s
  value_data = 1234 + rand(i)

  DB_Table.insert(created: time_data,
                  node: node_data,
                  value: value_data
                 )
end
sleep(2)

# this time, do 10 reps with consistent node name
(0..10).each do |i|
  time_data = Time.now
  node_data = 'FACEYMYBOOKY.com'
  value_data = 1234 + rand(i)

  DB_Table.insert(created: time_data,
                  node: node_data,
                  value: value_data
                 )
end

# AFTER
puts 'After:'
puts DB_Table.all
puts '^AFTER^AFTER^AFTER^AFTER^AFTER^AFTER^AFTER^AFTER^AFTER^AFTER'
puts
