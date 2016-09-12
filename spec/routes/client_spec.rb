require_relative '../spec_helper.rb'

describe 'The Clients endpoint' do
  def app
    Iam
  end

  include Rack::Test::Methods

  before(:all) do
    # anything that should happen before all tests
  end

  it 'responds OK' do
    get '/clients'
    expect(last_response).to be_ok
    get '/clients/'
    expect(last_response).to be_ok
  end

  it 'includes the names of existing clients' do
    FactoryGirl.create(:client, name: 'Client X')
    FactoryGirl.create(:client, name: 'Client Y')
    FactoryGirl.create(:client, name: 'Client Z')

    get 'clients'

    expect(last_response.body).to include('Client X')
    expect(last_response.body).to include('Client Y')
    expect(last_response.body).to include('Client Z')
  end

  it 'displays a specific client by id' do
    client = Client.create(name: 'New Client')
    get "/clients/#{client.id}"
    expect(last_response.body).to include('New Client')
  end

  it 'answers 404 when asked for a non-existent client' do
    get '/clients/1200438'
    expect(last_response.status).to eq(404)
  end

  it 'responds ok when asked for clients/new' do
    get '/clients/new'
    expect(last_response.status).to eq(200)
  end

  it 'responds ok when asked for the form to edit an existing client' do
    client = Client.create(name: 'Editable')
    get "/clients/#{client.id}/edit"
    expect(last_response.status).to eq(200)
  end

  it 'responds 404 when asked for the form to edit an absent client' do
    get '/clients/9884093/edit'
    expect(last_response.status).to eq(404)
  end

  it 'allows us to create a new client, then redirects to the list' do
    post '/clients', name: "I'm new!"

    client = Client[name: "I'm new!"]
    expect(client).to exist
    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_request.path).to eq("/clients/#{client.id}")
    expect(last_response.body).to include("I'm new!")

    get "/clients/#{client.id}"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("I'm new!")
  end

  it 'allows us to edit a client, then redirects to the list' do
    client = Client.create(name: 'Edit Me')

    edited_client = { id: client.id,
                      name: 'Edited Client',
                      description: client.description,
                      contact_name: client.contact_name,
                      contact_email: client.contact_email }

    patch '/clients', edited_client

    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_response.status).to eq(200)
    expect(last_request.path).to eq("/clients/#{client.id}")
    expect(last_response.body).to include('Edited Client')
  end

  it 'allows us to edit a single client field then redirects to the list' do
    client = Client.create(name: 'Edit Description', description: 'Boring')

    edited_client = { id: client.id, description: 'Not Boring!' }

    patch '/clients', edited_client

    expect(Client[name: 'Edit Description'].description).to eq('Not Boring!')

    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_request.path).to eq("/clients/#{client.id}")
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('Not Boring!')
  end

  # sinatra has no way of checking which template is rendered, so we will
  # check for HTML code
  it '/clients renders the index template' do
    get '/clients'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('Clients List')
  end

  it '/clients/new renders the create template' do
    get '/clients/new'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('name="createForm"')
  end

  it '/clients/1 renders the show template' do
    get '/clients/1'
    if last_response.status == 200
      # id found
      expect(last_response.body).to include('/clients/1/edit')
    else
      # id not found
      expect(last_response.status).to eq(404)
    end
  end

  it '/clients/1/edit renders the edit template' do
    get '/clients/1/edit'
    if last_response.status == 200
      # id found
      expect(last_response.body).to include(
        '<input type="hidden" name="_method" value="patch">'
      )
    else
      # id not found
      expect(last_response.status).to eq(404)
    end
  end
end
