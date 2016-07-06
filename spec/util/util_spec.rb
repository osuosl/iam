require File.expand_path '../../spec_helper.rb', __FILE__
require 'time'
require_relative '../../util.rb'

describe 'The Utility tests' do
  def app
    Iam
  end

  include Rack::Test::Methods

  before(:all) do
    # anything that should happen before all tests
    
    # data from report method from plugin
    # to test for max: 80
    # to test for min: 2
    # to test for average: 25

    @data_max_80 = [
      { id: 1, node_resource: nil,
        created: Time.parse('2016-07-01 21:43:27 +0000'),
        node: 'alembic-java.osuosl.org', value: 14, active: true },
      { id: 2, node_resource: nil,
        created: Time.parse('2016-07-01 21:43:27 +0000'),
        node: 'amahi.osuosl.org', value: 2, active: true },
      { id: 3, node_resource: nil,
        created: Time.parse('2016-07-01 21:43:28 +0000'),
        node: 'answers.ros.osuosl.org', value: 80, active: true },
      { id: 4, node_resource: nil,
        created: Time.parse('2016-07-01 21:43:27 +0000'),
        node: 'cthalmann.osuosl.org', value: 4, active: true }
    ]

  end

  
  it 'returns the max value' do
    expect(Util.maxValue(@data_max_80)).to eq(80)
  end

  it 'returns the min value' do
    expect(Util.minValue(@data_max_80)).to eq(2)
  end

  it 'returns the average value' do
    expect(Util.averageValue(@data_max_80).to eq(25)
  end
  # Test ideas:
  # date
  # => is date after today's date?
  # => is date earlier than date range?
  # values
  # => is value negative?  Should it be?
  # => is value greater than max?  Does it become new max?
  # => same for min

  # it 'says hello' do
  #   get '/'
  #   expect(last_response).to be_ok
  #   expect(last_response.body).to eq('Hello')
  # end
end
