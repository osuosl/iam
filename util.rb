require 'sinatra/base'
require_relative 'environment'

# IAM - a resource usage metric collection and reporting system
class Util
  def self.val_id(data)
    # checks if the hashes are empty
    # checks if the values of id are fixed numbers
    return 0 if data.empty?
    data.each do |item|
      id = item[:id]
      return false if id.class != Fixnum
    end
    true
  end

  def self.id_not_neg(data)
    # checks if the id is not negative
    data.each do |item|
      return false if item[:id] <= 0
    end
    true
  end

  def self.avg_val(data)
    # returns the average of values
    data.map { |a| a[:value] }.reduce(:+) / data.length
  end

  def self.min_val(data)
    # return the minimum of values
    return 0 if data.empty?
    data.min { |a, b| a[:value] <=> b[:value] }[:value]
  end

  def self.max_val(data)
    # return the maximum of values
    return 0 if data.empty?
    data.max { |a, b| a[:value] <=> b[:value] }[:value]
  end
end
