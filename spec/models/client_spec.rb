require File.expand_path '../../model_spec_helper.rb', __FILE__

describe 'The Client Model and table' do
  def app
    Iam
  end

  include Rack::Test::Methods

  it "has no clients" do
  	expect(Client.all).to be_empty
  end

  it "has a name" do
	expect(Client.name).to eq('Client')
  end
end