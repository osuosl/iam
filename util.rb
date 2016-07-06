require 'sinatra/base'
require_relative 'environment'

# IAM - a resource usage metric collection and reporting system
class Util

  def self.maxValue(data)
    # write code here to find the max value
    return 80
  end
  def self.minValue(data)
    # write code here to find the max value
    min = data[0][:value]
    for number in data
      compareMin = number[:value]
      if min > compareMin
        min = compareMin
      end
    end 
    return min
  end
end
