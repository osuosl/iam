require 'sinatra/base'
require_relative 'environment'

# IAM - a resource usage metric collection and reporting system
class Util
  def self.max_value(data)
    if data.empty?
      return 0
    end
    max = data[0][:value]
    data.each do |item|
      compare_max = item[:value]
      if max < compare_max
        max = compare_max
      end
    end
    return max
  end

  def self.min_value(data)
    return 0 if data.empty?
    min = data[0][:value]
    data.each do |item|
      compare_min = item[:value]
      if min > compare_min
        min = compare_min
      end
    end
    return min
  end

  def self.average_value(data)
    if data.empty?
      return 0
    end
    average = data[0][:value]
    count = 1
    data.slice(1..-1).each do |item|
      average += item[:value]
      count += 1
    end
    average /= count
    return average
  end

  def self.is_positive_integer_value(data)
    flag = true
    i = 0
    while i < data.length && flag != false
      if data[i][:value].is_a? Integer
        if data[i][:value] < 0
          flag = false
        end
      else
        flag = false
      end
      i += 1
    end
    return flag
  end
end
