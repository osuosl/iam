require File.expand_path '../../spec_helper.rb', __FILE__

describe 'The Client list endpoint' do
  def app
    Iam
  end

  include Rack::Test::Methods

  before(:all) do
    FactoryGirl.create(:client, name: 'Client X')
  end

  it 'responds OK' do
    get '/clients'
    expect(last_response).to be_ok
  end

  it 'contains the name of a client we added' do
    get '/clients'
    expect(last_response).to match(/Client X/)
  end
end
