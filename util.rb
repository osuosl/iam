require 'sinatra/base'
require_relative 'environment'

# IAM - a resource usage metric collection and reporting system
class Util
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
end
