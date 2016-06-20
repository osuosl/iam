require 'json'
require 'erb'
require 'fileutils'
require_relative '../environment.rb'

# A simple file-based caching system.
# Replaces our use of redis.
# A thin vineer above a cache layer.
class Cache
  # Initialize the cache
  def initialize(file_path=ENV['CACHE_FILE'])
    @path = if file_path.to_s.empty? then '/tmp/iam-cache' else file_path end
    @hash = read
  end

  # Set a value in the ruby hash.
  # This is a dumb key:value store so you could store non strings as values,
  # but most of our code will assume the values are limited to strings.
  # Just something to keep in mind.
  def set(key, val)
    @hash[key] = val
  end

  # Get a value from the ruby hash.
  def get(key)
    @hash[key]
  end

  # Remove an entry from the hash
  def del(key)
    @hash.delete(key)
  end

  # Write the cache to a file in JSON.
  # Obliterates existing file with new contents.
  def write
    __ensure_path
    File.open(@path, "w") do |f|
      f.write(JSON.generate(@hash))
    end
  end

  # Read the cache file into a ruby hash `@hash`.
  # Return an empty hash if the file does note exist.
  def read
    __ensure_path
    if File.file?(@path)
      return JSON.parse(File.read(@path))
    else
      return Hash.new
    end
  end

  def keys
    return @hash.keys
  end

  def __ensure_path
    directory = File.dirname(@path)
    FileUtils.mkdir_p(directory) unless File.directory?(directory)
  end
end
