require 'logging'

describe 'The Logging application' do
  def app
    Iam
  end
  before(:all) do
    ::Logging.init
    @levels = ::Logging::LEVELS
    @event = ::Logging::LogEvent.new('logger', @levels['debug'],
    'testOutput', false)
  end

  it 'should output correct message' do
    expect(@event[:data]).to eq('testOutput')
  end
end
