require File.expand_path '../../spec_helper.rb', __FILE__


describe 'The Logging application' do
  def app
    Iam
  end
  include Rack::Test::Methods

  it 'log_file should not be empty' do
    expect('../../logging/log_file.log').to_not eq(nil)
  end
end
