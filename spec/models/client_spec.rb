require File.expand_path '../../model_spec_helper.rb', __FILE__
require File.expand_path '../../../models.rb', __FILE__

describe 'The Client Model and table' do
  include Rack::Test::Methods
  let(:db) { Sequel.sqlite }
  before { Sequel::Migrator.run(db, "migrations") }
  after { db.disconnect }
  def app
    Iam
  end

  it "has a database table" do
  	expect(db[:clients]).to be_empty
  end

  it "has a name" do
	expect(Client.name).to eq('Client')
  end

end