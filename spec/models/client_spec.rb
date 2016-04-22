require File.expand_path '../../spec_helper.rb', __FILE__

describe 'The Client Model and table' do
  def app
    Iam
  end

  include Rack::Test::Methods

  it "can create a client" do
    client = Client.create(:name => 'Testo')
    expect(client).to exist
  end

  it "has no clients" do
  	expect(Client.all).to be_empty
  end

  it "has a name" do
	expect(Client.name).to eq('Client')
  end
end