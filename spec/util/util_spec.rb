require File.expand_path '../../spec_helper.rb', __FILE__
require_relative '../../util.rb'
require 'time'

describe 'The Utility tests' do
  def app
    Iam
  end

  include Rack::Test::Methods

  before(:all) do
    # anything that should happen before all tests
    # Make several data sets with known expected results:
    # Sample data has a min of 3, max of 80, avg of 33
    @sample_data = [
      { id: 1, node_resource: nil,
        created: Time.parse('2016-07-01 21:43:27 +0000'),
        node: 'alembic-java.osuosl.org', value: 3, active: true },
      { id: 2, node_resource: nil,
        created: Time.parse('2016-07-01 21:43:27 +0000'),
        node: 'amahi.osuosl.org', value: 4, active: true },
      { id: 3, node_resource: nil,
        created: Time.parse('2016-07-01 21:43:28 +0000'),
        node: 'answers.ros.osuosl.org', value: 5, active: true }
    ]
  end

  context 'id validation' do
    # checks if the @sample_data has fixed numeric  id values
    it 'val_id checks for a numeric value' do
      expect(Util.val_id(@sample_data)).to eq(true)
    end
    # checks if the id is a positive number
    it 'id_not_neg checks for positive number' do
      expect(Util.id_not_neg(@sample_data)).to eq(true)
    end
  end

  context 'value validation' do
    # tests for average number
    it 'avg_val returns average of values' do
      expect(Util.avg_val(@sample_data)).to eq(4)
    end
    # tests for minimum number
    it 'min_val returns the minimum of values' do
      expect(Util.min_val(@sample_data)).to eq(3)
    end
    # tests for maximum number
    it 'max_val returns the maximum of values' do
      expect(Util.max_val(@sample_data)).to eq(5)
    end
  end
end
