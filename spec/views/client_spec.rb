require File.expand_path '../../spec_helper.rb', __FILE__

describe 'The Client list endpoint' do
  include Rack::Test::Methods

  let(:db) { Sequel.sqlite }
  before { Sequel::Migrator.run(db, "migrations") }
  after { db.disconnect }

  def app
    Iam
  end

  before { FactoryGirl.create_list(:client, 3) }

  it "provides a list of existing clients" do
  	get '/clients'
  	expect(last_response).to be_ok

  end

end
