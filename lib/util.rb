require 'sinatra/base'
require 'environment'
require 'time'

# Util is a class of utility methods
class Util
  def self.max_value(data)
    # Return the maximum value field from a list of hashes
    # an empty list should return 0
    return 0 if data.empty?
    max = data.first[:value]
    data.each do |line|
      max = line[:value] if line[:value] > max
    end
    max # return
  end # maxValue

  def self.min_value(data)
    # Return the minimum Value field in a list of hashes
    # an empty list should return 0
    return 0 if data.empty?
    min = data.first[:value]
    data.each do |line|
      min = line[:value] if line[:value] < min
    end
    min # return
  end # minValue

  def self.avg_value(data)
    # Return the avg (mean) Value field in a list of hashes
    # an empty list should return 0
    return 0 if data.empty?
    total = 0
    data.each do |line|
      total += line[:value]
    end
    total /= data.length
  end # avgValue

  def self.days_in_range(data)
    # Return number of days in range of data
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
  end # daysInRange
end # util class
