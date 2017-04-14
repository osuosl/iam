require File.expand_path '../../spec_helper.rb', __FILE__
require_relative '../../lib/util.rb'
require 'time'

describe 'The DataUtil class tests' do
  def app
    Iam
  end

  include Rack::Test::Methods
  before(:all) do
    # sample data from report method
    # to test for max: 80
    # to test for min: 2
    # to test for average: 25
    @test_data = [
      { id: 1, node_resource: nil,
        created: Time.parse('2016-07-01 21:43:27 +0000'),
        node: 'alembic-java.osuosl.org', value: 14, active: true },
      { id: 2, node_resource: nil,
        created: Time.parse('2016-07-02 21:43:27 +0000'),
        node: 'amahi.osuosl.org', value: 2, active: true },
      { id: 3, node_resource: nil,
        created: Time.parse('2016-07-03 21:43:28 +0000'),
        node: 'answers.ros.osuosl.org', value: 80, active: true },
      { id: 4, node_resource: nil,
        created: Time.parse('2016-07-01 21:43:27 +0000'),
        node: 'cthalmann.osuosl.org', value: 4, active: true }
    ]
    # test data of several hashes in the same day
    @data_several_1day = [
      { id: 1, node_resource: nil,
        created: Time.parse('2015-06-01 1:43:27 +0000'),
        node: 'alembic-java.osuosl.org', value: 3, active: true },
      { id: 2, node_resource: nil,
        created: Time.parse('2015-06-01 10:43:27 +0000'),
        node: 'alembic-java.osuosl.org', value: 5, active: true }
    ]
    # test data from June 1 to June 7 (~7 days inclusive)
    @data_7days = [
      { id: 1, node_resource: nil,
        created: Time.parse('2015-06-01 21:43:27 +0000'),
        node: 'alembic-java.osuosl.org', value: 3, active: true },
      { id: 2, node_resource: nil,
        created: Time.parse('2015-06-04 21:43:27 +0000'),
        node: 'amahi.osuosl.org', value: 16, active: true },
      { id: 3, node_resource: nil,
        created: Time.parse('2015-06-07 21:43:28 +0000'),
        node: 'answers.ros.osuosl.org', value: 80, active: true }
    ]
    # test data includes invalid date (in the future)
    @data_future = [
      { id: 3, node_resource: nil,
        created: Time.now + 100,
        node: 'answers.ros.osuosl.org', value: 80, active: true }
    ]
    # test data spans a leap year.
    # 2016 was a leap year, so feb 2016 should have 29 days + march 1 = ~30
    @data_leap_year = [
      { id: 1, node_resource: nil,
        created: Time.parse('2016-02-01 12:00:00 +0000'),
        node: 'alembic-java.osuosl.org', value: 3, active: true },
      { id: 17, node_resource: nil,
        created: Time.parse('2016-03-01 12:00:01 +0000'),
        node: 'answers.ros.osuosl.org', value: 80, active: true }
    ]
    # test data does NOT span a leap year.
    # 2015 was NOT a leap year, so feb 2015 should have 28 days + march 1 = ~29
    @data_no_leap_year = [
      { id: 1, node_resource: nil,
        created: Time.parse('2015-02-01 12:00:00 +0000'),
        node: 'alembic-java.osuosl.org', value: 3, active: true },
      { id: 17, node_resource: nil,
        created: Time.parse('2015-03-01 12:00:01 +0000'),
        node: 'answers.ros.osuosl.org', value: 80, active: true }
    ]
    # test data across 2 days at an identical time of day
    @data_matching_times = [
      { id: 1, node_resource: nil,
        created: Time.parse('2015-06-01 1:00:00 +0000'),
        node: 'alembic-java.osuosl.org', value: 3, active: true },
      { id: 3, node_resource: nil,
        created: Time.parse('2015-06-02 1:00:00 +0000'),
        node: 'answers.ros.osuosl.org', value: 80, active: true }
    ]
    # test data includes invalid data type (string)
    @data_invalid = [
      { id: 1, node_resource: nil,
        created: '2016-07-01 21:43:27 +0000',
        node: 'alembic-java.osuosl.org', value: -3, active: true }
    ]
    @data_empty = []
    @data_hash_empty = {}
  end

  describe 'the max_value method' do
    it 'returns the max value' do
      expect(DataUtil.max_value(@test_data)).to eq(80)
    end

    it 'returns 0 for max value if array is empty' do
      expect(DataUtil.max_value(@data_empty)).to eq(0)
    end
  end

  describe 'the min_value method' do
    it 'returns the min value' do
      expect(DataUtil.min_value(@test_data)).to eq(2)
    end

    it 'returns 0 for min value if array is empty' do
      expect(DataUtil.min_value(@data_empty)).to eq(0)
    end
  end

  describe 'the average_value method' do
    it 'returns the average value' do
      expect(DataUtil.average_value(@test_data)).to eq(25)
    end

    it 'returns 0 for average of values if array is empty' do
      expect(DataUtil.average_value(@data_empty)).to eq(0)
    end
  end

  describe 'the days_in_range method' do
    it 'properly handles a range of dates with identical times of day' do
      expect(DataUtil.days_in_range(@data_matching_times)).to eq(2.0)
    end
    it 'returns correct number of days in a range' do
      expect(DataUtil.days_in_range(@test_data)).to be_within(0.01).of(3)
      expect(DataUtil.days_in_range(@data_7days)).to be_within(0.1).of(7)
      expect(DataUtil.days_in_range(@data_empty)).to eq(0)
    end
    it 'returns 1.0 for a single day' do
      expect(DataUtil.days_in_range([@data_several_1day.first])).to eq(1.0)
      expect(DataUtil.days_in_range(@data_several_1day))
        .to be_within(0.5).of(1.0)
    end
    it 'properly handles leap years' do
      expect(DataUtil.days_in_range(@data_leap_year))
        .to be_within(0.01).of(30)
      expect(DataUtil.days_in_range(@data_no_leap_year))
        .to be_within(0.01).of(29)
    end
    it 'returns nil if called with invalid data' do
      expect(DataUtil.days_in_range(@data_invalid)).to eq(nil)
      expect(DataUtil.days_in_range(@data_future)).to eq(nil)
    end
  end

  describe 'the sum_data method' do
    it "properly handles a 'plain' DiskTemplate" do
      expect(DataUtil.sum_data(@data_hash_empty, 'DiskSize', 10, 0)).to eq(10)
    end
    it "properly handles a 'drdb' DiskTemplate" do
      expect(DataUtil.sum_data(@data_hash_empty, 'DiskSize', 10, 1)).to eq(20)
    end
  end
end
