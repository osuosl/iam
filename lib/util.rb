# frozen_string_literal: true
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

  # this method takes a hash of  measurments and performs calculations based on
  # the type of data, then adds their value to the final hash of sums
  def self.sum_data(sums, key, value, drdb)
    drdb = 1 if drdb.nil?
    # convert value to minimum billable for DBSize if value < 1
    value = value < 1 && value > 0.00 && key == 'DBSize' ? 1 : value
    # if sums already contains this key, add the value to the existing value;
    # else add the key and value to sums
    sums[key] = if sums.key?(key)
                  (value * drdb) + sums[key]
                else
                  value * drdb
                end
  end

  # this method converts units of plugins from their original form to GB
  def self.unit_conversion(key, value)
    # convervion from MB -> GB and bytes -> GB
    value = if %w(RamSize DiskSize).include?(key)
              # convert from MB -> GB
              ((value / 1024.00) * 100).round.to_f / 100
            elsif key == 'DBSize'
              # convert from Bytes -> GB
              (value / (1024.00 * 1024.00 * 1024.00) * 100).round.to_f / 100
            else
              # no conversion needed
              value
            end
    value
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

  # this method takes a project and resource type then returns a specific number
  # of measurements according to how many were specified by per_page
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
          data_average = data.nil? ? 0 : DataUtil.average_value(data)
          plugin_data[resource.name].merge!(measurement => data_average)
        end
      end
      (resource_data[resource_type] ||= []) << (
                                    @page_count / per_page.to_f).ceil
      (resource_data[resource_type] ||= []) << plugin_data
    end
    resource_data
  end

  # this method takes a list of project ids and returns a nice hash of all their
  # resources and their measurments

  def self.project_data(project_ids, start_date, end_date)
    project_data = {}

    plugin_tables = Plugin.select_map([:name, :resource_name, :storage_table])

    plugin_tables.each do |row|
      resource_key = (row[1] + '_resource').to_sym
      resources_table = (row[1] + '_resources').to_sym
      project_data[row[1]] ||= {}

      data = Iam.settings.DB[resources_table].where(project_id: project_ids)
                .join_table(:inner,
                            Iam.settings.DB[row[2].to_sym],
                            resource_key => :id,
                            created: start_date..end_date)
                .select_hash_groups([resource_key, row[1].to_sym], :value)

      data.each do |keys, values|
        res_name = keys[1]
        res_id = keys[0]

        if values[0].is_a? String
          average = values[0]
        else
          # get the average of the values
          average = (values.inject { |a, e| a + e }.to_f / values.size).to_i
        end

        meas_array = { res_name => { id: res_id, row[0].to_sym => average } }

        project_data[row[1]][res_name] ||= {}
        project_data[row[1]][res_name].merge!(meas_array[res_name])
      end
    end
    project_data
  end

  # this method takes a hash of data and two dates. It takes the data that falls
  # between the two dates, then returns the sum of their measurements
  def self.sum_data_in_range(input_hash)
    sum = {}
    input_hash.each do |_project_name, resource_hash|
      resource_hash.each do |_res_type, resources|
        resources.each do |_res_name, meas_hash|
          # Isolate each projects resource then get those that fall between the
          # start and end date.
          meas_hash.each do |meas, value|
            next if %w(id).include?(meas) || value.nil?
            drdb = value == 'plain' ? 1 : 2

            if meas == :DiskTemplate
              sum[meas] = '-'
            else
              DataUtil.sum_data(sum, meas, value, drdb)
            end
          end
        end
      end
    end
    sum
  end
end
