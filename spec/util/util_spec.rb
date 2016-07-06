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
    @sample_data = [
      { id: 1, node_resource: nil,
        created: Time.parse('2016-07-01 21:43:27 +0000'),
        node: 'alembic-java.osuosl.org', value: 3, active: true},
      { id: 2, node_resource: nil,
        created: Time.parse('2016-07-01 21:43:27 +0000'),
        node: "amahi.osuosl.org", value: 16, active: true },
      { id: 3, node_resource: nil,
        created: Time.parse('2016-07-01 21:43:28 +0000'),
        node: 'answers.ros.osuosl.org', value: 80, active: true }
    ]
  end

  it 'maxValue returns correct value' do
    expect(Util.max_value(@sample_data)).to eq(80)
  end

  it 'minValue returns correct value' do
    expect(Util.min_value(@sample_data)).to eq(3)
  end

  it 'avgValue returns correct value' do
    expect(Util.avg_mean_value(@sample_data)).to eq(33)
  end
end
