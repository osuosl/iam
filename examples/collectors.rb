require_relative '../collectors.rb'

c = Collectors.new

# TODO: Replace with file-evaluated variable.
clusters = ['ganeti']

puts 'Running ganeti/nodes collector'
# Run the node collector
clusters.each do |var|
  c.collect_ganeti(var)
end

# TODO: Replace with file-evaluated variable.
db_creds = [{ type: :mysql,
              host: ENV['MYSQL_TESTING_HOST'],
              user: ENV['MYSQL_USER'],
              password: ENV['MYSQL_PASSWORD'] }]

puts 'Running database collector'
# Run the database collector
db_creds.each do |var|
  c.collect_db(var[:type], var[:host], var[:user], var[:password])
end
