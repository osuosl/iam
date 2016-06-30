require File.expand_path '../../spec_helper.rb', __FILE__

describe 'The utility tests' do
  def app
    Iam
  end

  include Rack::Test::Methods

  def app
    Iam
  end

  before(:all) do
    # anything that should happen before all tests
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
