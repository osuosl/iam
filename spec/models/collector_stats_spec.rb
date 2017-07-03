# frozen_string_literal: true
require File.expand_path '../../spec_helper.rb', __FILE__

describe 'The Collector Stats Model and table' do
  def app
    Iam
  end
  include Rack::Test::Methods

  it 'creation of stat fails if no name is given' do
    expect do
      CollectorStat.create
    end.to raise_error(Sequel::ValidationFailed, /name cannot be empty/)
  end

  it 'can create a stat' do
    stat = CollectorStat.create(name: 'testo')
    expect(stat).to exist
  end

  it 'two statistics can have the same name' do
    CollectorStat.create(name: 'testo')
    expect { CollectorStat.create(name: 'testo') }.to_not raise_error
  end

  it 'has a success flag' do
    stat = CollectorStat.create(name: 'testo', success: true)
    expect(stat).to exist
    expect(stat.success).to be true
  end
end
