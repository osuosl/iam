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
    (data.reduce(0) { |a, e| a + e[:value].to_i }) / data.length
  end

  # Return the number of days in a range of hashes
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
        resource_data[resource.name]['id'] = resource[:id]
        if resource_type == 'node'
          drdb = DiskTemplate.new.report(node: resource.name)
          if drdb.empty?
            drdb = 0
          else
            drdb = drdb[0]
            drdb = drdb.fetch(:value).to_i
          end
          resource_data[resource.name]['drdb'] = drdb
        end
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
          resource_data[resource.name].merge!(measurement => data_average)
        end
      end
      (project_data[resource_type] ||= []) << resource_data
    end
    project_data
  end

  def self.sum_data(input_hash, start_date, end_date)
    sum = {}
    start_date = Time.at(start_date.to_i)
    end_date = Time.at(end_date.to_i)

    input_hash.each do |_project_name, project_resource|
      project_resource.each do |resource|
        resource.each do |res_type, resource_hash|
          # Add hashes for each resource into the main sum hash
          sum[res_type] ||= {}
          # Isolate each projects resource then get those that fall between the
          # start and end date.
          resource_hash.each do |hash, _value|
            hash.each do |resource_name, meas_hash|
              meas_hash.each do |meas_key, _meas_value|
                if meas_key != 'id' && meas_key != 'drdb'
                  # Turn the key string into a class and use it to call to the
                  # BasePlugin report method
                  meas_class = meas_key.constantize
                  if start_date != end_date
                    h = meas_class.new.report({ "#{res_type}": resource_name },
                                              start_date, end_date)
                  else
                    h = meas_class.new.report({ "#{res_type}": resource_name })
                  end
                  # Transform array to hash. Insures all hashes are not nil,
                  # then adds up all the resources
                  hash = h[0]
                  if hash.nil?
                    hash = Hash.new
                    hash[:value] = 0
                  end
                  value = hash.fetch(:value).to_i
                  if meas_hash.key?('drdb')
                    drdb = meas_hash.fetch('drdb').to_i + 1
                  else
                    drdb = 1
                  end
                  # If the measurement already exists in sum, add the new
                  # measurement value to the one in sum
                  if sum[res_type].key?(meas_key)
                    sum[res_type][meas_key] = (value * drdb) +
                                              sum[res_type][meas_key]
                  else
                    # Add the measurement value for the first time
                    sum[res_type][meas_key] =  value
                  end
                end
              end
            end
          end
        end
      end
    end
    sum
  end
end
