# frozen_string_literal: true
require File.expand_path '../../spec_helper.rb', __FILE__

describe 'The IAM Application' do
  include Rack::Test::Methods

  def app
    Iam
  end

  it 'says hello' do
    get '/'
    expect(last_response).to be_ok
    # This will be a more thorough test when we know what the home page will
    # *really* look like.
    expect(last_response.body).to include('<!-- HOMEPAGE -->')
  end
end
