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
    @data_empty = []
  end

  describe 'the util.max_value method' do
    it 'returns the max value' do
      expect(Util.max_value(@data_max_80)).to eq(80)
    end

    it 'returns 0 for max value if array is empty' do
      expect(Util.max_value(@data_empty)).to eq(0)
    end
  end

  describe 'the util.min_value method' do
    it 'returns the min value' do
      expect(Util.min_value(@data_max_80)).to eq(2)
    end

    it 'returns 0 for min value if array is empty' do
      expect(Util.min_value(@data_empty)).to eq(0)
    end
  end

  describe 'the util.average_value method' do
    it 'returns the average value' do
      expect(Util.average_value(@data_max_80)).to eq(25)
    end

    it 'returns 0 for average of values if array is empty' do
      expect(Util.average_value(@data_empty)).to eq(0)
    end
  end

  describe 'the util.is_positive_integer_value method' do
    it 'returns false if the value of an item in the array is not
    a positive integer' do
      @data_set_false = [
        { id: 1, node_resource: nil,
          created: Time.parse('2016-07-01 21:43:27 +0000'),
          node: 'alembic-java.osuosl.org', value: 14, active: true },
        { id: 2, node_resource: nil,
          created: Time.parse('2016-07-01 21:43:27 +0000'),
          node: 'amahi.osuosl.org', value: -2, active: true },
        { id: 3, node_resource: nil,
          created: Time.parse('2016-07-01 21:43:28 +0000'),
          node: 'answers.ros.osuosl.org', value: 80, active: true },
        { id: 4, node_resource: nil,
          created: Time.parse('2016-07-01 21:43:27 +0000'),
          node: 'cthalmann.osuosl.org', value: 4, active: true }
      ]

      expect(Util.is_positive_integer_value(@data_set_false)).to eq(false)
    end

    it 'returns true if all the values of all the items in the array are
    positive integers' do
      @data_set_true = [
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
      expect(Util.is_positive_integer_value(@data_set_true)).to eq(true)
    end
  end
end
