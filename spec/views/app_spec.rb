require File.expand_path '../../spec_helper.rb', __FILE__

describe 'The IAM Application' do
  include Rack::Test::Methods

  def app
    Iam
  end

  it "says hello" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('Hello')
  end

end
