require 'sinatra/base'
require_relative 'environment'

# IAM - a resource usage metric collection and reporting system
class Util
  def self.max_value(data)
    return 0 if data.empty?
    max = data[0][:value]
    data.each do |item|
      compare_max = item[:value]
      max = compare_max if max < compare_max
    end
    max
  end

  def self.min_value(data)
    return 0 if data.empty?
    min = data[0][:value]
    data.each do |item|
      compare_min = item[:value]
      min = compare_min if min > compare_min
    end
    min
  end

  def self.average_value(data)
    return 0 if data.empty?
    average = data[0][:value]
    count = 1
    data.slice(1..-1).each do |item|
      average += item[:value]
      count += 1
    end
    average /= count
    average
  end

  def self.positive_integer_value?(data)
    flag = true
    i = 0
    while i < data.length && flag != false
      if data[i][:value].is_a? Integer
        flag = false if data[i][:value] < 0
      else
        flag = false
      end
      i += 1
    end
    flag
  end
end
