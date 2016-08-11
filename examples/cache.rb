require_relative '../lib/util.rb'

puts 'The following output will not make sense unless you read the script you
      are running (examples/cache.rb)'

# Create a new cache at
# Implicitly: Cache.initialize('/tmp/examplecache')
my_cache = Cache.new '/tmp/examplecache'

# Add two entries to the hash
my_cache.set 'abc', 'value1'
my_cache.set 'xyz', 'value2'
my_cache.set '123', 'value3'

# Write the cache to a file
my_cache.write

# Print individual cache items
puts my_cache.get 'abc'
puts my_cache.get '123'

# See all keys you can access in the cache
puts my_cache.keys

# Remove entry from cache
# Not removed from file, just in-memory data-struture
my_cache.del('xyz')

# Manually read from the cache file
# Restores 2 to the cache
my_cache.read

puts my_cache      # prints object stuff
puts my_cache.hash # prints a number. TODO figure out why.
puts my_cache.dump # prints the actual hash
