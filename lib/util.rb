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
  def initialize(file_path = "#{Iam.settings.cache_path}/test_cache")
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

# methods for gathering measurement data into hashes
class Report
  # this method returns all the available resource type along with an array
  # of the measurment plugins available for that resource type
  def self.plugin_matrix
    matrix = {}
    # query the plugins model to determine what measurements are available
    plugins = Plugin.all
    # make a matrix of resource types and their plugins
    # { 'node': ['DiskSize', 'VCPU', ...]
    #   'db': ['Size', ...]
    #   ...}
    plugins.each do |plugin|
      next if plugin.name == 'TestingPlugin'
      (matrix[plugin.resource_name] ||= []) << plugin.name
    end
    matrix
  end

  def self.get_data(project, page, per_page, res)
    resource_data = {}

    # for each resource type in the matrix, get a list of all that type
    # of resource each project has
    plugin_matrix.each do |resource_type, measurements|
      plugin_data = {}
      @page_count = project.send("#{res}_resources").count

      all_resources = project.send("#{res}_resources")[
            ((page - 1) * per_page...(page * per_page))
          ]

      next unless resource_type == res
      # for each of those resources, get all the measuremnts for that
      # type of resource. Put it all in a big hash.
      all_resources.each do |resource|
        plugin_data[resource.name] ||= {}
        plugin_data[resource.name]['id'] = resource[:id]
        measurements.each do |measurement|
          plugin = Object.const_get(measurement).new
          data = plugin.report(resource_type.to_sym => resource.name)
          if data[0].nil?
            data_average = 0
          else
            data_average = if data[0][:value].number?
                             DataUtil.average_value(data)
                           else
                             data[-1][:value]
                           end
          end
          plugin_data[resource.name].merge!(measurement => data_average)
        end
      end
      (resource_data[resource_type] ||= []) << (
                        @page_count / per_page.to_f).ceil
      (resource_data[resource_type] ||= []) << plugin_data
    end
    resource_data
  end

  # this method takes a project name and returns a nice hash of all its
  # resources and their measurments
  def self.project_data(project)
    project_data = {}

    # for each resource type in the matrix, get a list of all that type
    # of resource each project has
    plugin_matrix.each do |resource_type, measurements|
      resource_data = {}
      resources = project.send("#{resource_type}_resources")
      next if resources.nil?
      # for each of those resources, get all the measuremnts for that
      # type of resource. Put it all in a big hash.
      resources.each do |resource|
        resource_data[resource.name] ||= {}
        measurements.each do |measurement|
          plugin = Object.const_get(measurement).new
          data = plugin.report(resource_type.to_sym => resource.name)
          next if data[0].nil?
          data_average = if data[0][:value].number?
                           DataUtil.average_value(data)
                         else
                           data[-1][:value]
                         end
          resource_data[resource.name].merge!(measurement => data_average)
        end
      end
      (project_data[resource_type] ||= []) << resource_data
    end
    project_data
  end
end
