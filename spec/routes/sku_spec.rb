# frozen_string_literal: true
require_relative '../spec_helper.rb'

describe 'The skus endpoint' do
  def app
    Iam
  end

  include Rack::Test::Methods

  before(:all) do
    # anything that should happen before all tests
  end

  it 'responds OK' do
    get '/skus'
    expect(last_response).to be_ok
    get '/skus/'
    expect(last_response).to be_ok
  end

  it 'verifies the default project exists' do
    sku = Sku.find(name: 'default')
    expect(sku).to exist
    get "/skus/#{sku.id}"
    expect(last_response.status).to eq(200)
  end

  it 'includes the names of existing skus' do
    FactoryGirl.create(:sku, name: 'sku X')
    FactoryGirl.create(:sku, name: 'sku Y')
    FactoryGirl.create(:sku, name: 'sku Z')

    get '/skus/'

    expect(last_response.body).to include('sku X')
    expect(last_response.body).to include('sku Y')
    expect(last_response.body).to include('sku Z')
  end

  it 'displays a specific sku by id' do
    sku = Sku.create(name: 'New sku')
    get "/skus/#{sku.id}"
    expect(last_response.body).to include('New sku')
  end

  it 'answers 404 when asked for a non-existent sku' do
    get '/skus/1230484/'
    expect(last_response.status).to eq(404)
  end

  it 'responds ok when asked for skus/new' do
    get '/skus/new'
    expect(last_response.status).to eq(200)
  end

  it 'responds ok when asked for the form to edit an existing sku' do
    sku = Sku.create(name: 'Editable')
    get "/skus/#{sku.id}/edit"
    expect(last_response.status).to eq(200)
  end

  it 'responds 404 when asked for the form to edit an absent sku' do
    get '/skus/9884093/edit'
    expect(last_response.status).to eq(404)
  end

  it 'allows us to create a new sku, then redirects to the list' do
    post '/skus', name: 'im new'

    sku = Sku.find(name: 'im new')
    expect(sku).to exist
    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_request.path).to eq("/skus/#{sku.id}")
    expect(last_response.body).to include('im new')

    get "/skus/#{sku.id}"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('im new')
  end

  it 'allows us to edit a sku, then redirects to the list' do
    sku = Sku.create(name: 'Edit Me')

    edited_sku = { id: sku.id,
                   name: 'Edited sku' }

    patch '/skus', edited_sku

    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_response.status).to eq(200)
    expect(last_request.path).to eq("/skus/#{sku.id}")
    expect(last_response.body).to include('Edited sku')
  end

  it 'allows us to edit a single sku field then redirects to the list' do
    sku = Sku.create(name: 'Edit Description', description: 'unedited')
    edited_sku = { id: sku.id, description: 'i edited this' }

    patch '/skus', edited_sku

    expect(Sku[name: 'Edit Description'].description).to eq('i edited this')

    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_request.path).to eq("/skus/#{sku.id}")
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('i edited this')
  end

  it 'cannot create a sku with a non-unique name' do
    sku1 = Sku.create(name: 'sku1')

    expect(sku1).to exist

    expect do
      Sku.create(name: 'sku1')
    end.to raise_error(StandardError)
  end
end
