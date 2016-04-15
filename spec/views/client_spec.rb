require File.expand_path '../../spec_helper.rb', __FILE__

describe 'The Client list endpoint' do	
  def app
    Iam
  end

  include Rack::Test::Methods

  before { 
	FactoryGirl.create(:client, client_name: "Client X")
  }

  it "responds OK" do
  	get '/clients'
  	expect(last_response).to be_ok
  end

  it "contains the name of a client we added" do
  	get '/clients'
  	expect(last_response).to match(/Client X/)
  end
end
