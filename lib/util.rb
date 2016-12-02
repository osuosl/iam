require 'json'
require 'erb'
require 'fileutils'
require_relative '../environment.rb'
require 'sinatra/base'
require 'time'

# A simple file-based caching system.
# Replaces our use of redis.
# A thin vineer above a cache layer.
class Cache
  # Initialize the cache
  def initialize(file_path = Iam.settings.cache_path)
    @path = file_path.to_s.empty? ? '/tmp/iam-cache' : file_path
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
    File.open(@path, 'w') do |f|
      f.write(JSON.generate(@hash))
    end
  end

  # Read the cache file into a ruby hash `@hash`.
  # Return an empty hash if the file does note exist.
  def read
    __ensure_path
    @hash = if File.file?(@path)
              JSON.parse(File.read(@path))
            else
              {}
            end
    @hash
  end

  def keys
    @hash.keys
  end

  def dump
    @hash
  end

  def __ensure_path(fp = @path)
    directory = File.dirname(fp)
    FileUtils.mkdir_p(directory) unless File.directory?(directory)
  end
end

# helper function to determine if the object is a number or string
class Object
  def number?
    to_f.to_s == to_s || to_i.to_s == to_s
  end
end

# Class to find the min, max, and average of the values in the array of
# hashes from the report plugin method.
class DataUtil
  include Enumerable

  def self.max_value(data)
    return 0 if data.empty?
    (data.max { |a, b| a[:value] <=> b[:value] })[:value]
  end

  def self.min_value(data)
    return 0 if data.empty?
    (data.min { |a, b| a[:value] <=> b[:value] })[:value]
  end

  def self.average_value(data)
    return 0 if data.empty?
    (data.reduce(0) { |a, e| a + e[:value] }) / data.length
  end

  # Return the number of days in a range of hashes
  # rubocop:disable MethodLength, AbcSize
  def self.days_in_range(data)
    # an empty range is 0 days
    return 0 if data.empty?
    earliest = data.first[:created]
    latest = data.last[:created]
    now = Time.now()
    data.each do |line|
      l = line[:created]
      # dates must be in a Time format
      return nil if l.class != Time
      # dates cannot be in the future
      return nil if l > now
      earliest = l if l < earliest
      latest = l if l > latest
    end
    # latest-earliest is number of seconds BETWEEN two timestamps
    # there are 60*60*24 seconds in every day (even DST)
    # return 1 day minimum, rounded to 2 decimal places
    day = 60 * 60 * 24
    ((latest - earliest + day) / day).round(2)
  end
end
