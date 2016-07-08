require File.expand_path '../../spec_helper.rb', __FILE__
require 'time'
require_relative '../../lib/util.rb'

describe 'The Data Utility tests' do
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
    @test_data = [
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
    @data_empty = []
  end

  describe 'the util.max_value method' do
    it 'returns the max value' do
      expect(DataUtil.max_value(@test_data)).to eq(80)
    end

    it 'returns 0 for max value if array is empty' do
      expect(DataUtil.max_value(@data_empty)).to eq(0)
    end
  end

  describe 'the util.min_value method' do
    it 'returns the min value' do
      expect(DataUtil.min_value(@test_data)).to eq(2)
    end

    it 'returns 0 for min value if array is empty' do
      expect(DataUtil.min_value(@data_empty)).to eq(0)
    end
  end

  describe 'the util.average_value method' do
    it 'returns the average value' do
      expect(DataUtil.average_value(@test_data)).to eq(25)
    end

    it 'returns 0 for average of values if array is empty' do
      expect(DataUtil.average_value(@data_empty)).to eq(0)
    end
  end
end
