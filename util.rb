require 'sinatra/base'
require_relative 'environment'

# IAM - a resource usage metric collection and reporting system
class Util
  def self.max_value(data)
    # find the max Value
    return 0 if data.empty?
    data.max { |item, item2| item[:value].abs <=> item2[:value].abs }[:value]
  end

  def self.min_value(data)
    # find the lowest Value
    return 0 if data.empty?
    data.min { |item, item2| item[:value].abs <=> item2[:value].abs }[:value]
  end

  def self.avg_mean_value(data)
    # find the average(Mean) of the Values
    return 0 if data.empty?
    data.map { |item| item[:value].abs }.reduce(:+) / data.count
  end
end
