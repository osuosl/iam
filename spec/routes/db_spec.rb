# frozen_string_literal: true
require_relative '../spec_helper.rb'

describe 'The DbResource endpoint' do
  def app
    Iam
  end

  include Rack::Test::Methods

  before(:all) do
    # anything that should happen before all tests
  end

  it 'responds OK' do
    get '/dbs'
    expect(last_response).to be_ok
    get '/dbs/'
    expect(last_response).to be_ok
  end

  it 'includes the names of existing dbs' do
    DbResource.create(name: 'Db X')
    DbResource.create(name: 'Db Y')
    DbResource.create(name: 'Db Z')

    get 'dbs'

    expect(last_response.body).to include('Db X')
    expect(last_response.body).to include('Db Y')
    expect(last_response.body).to include('Db Z')
  end

  it 'displays a specific Db by id' do
    db = DbResource.create(name: 'New Db')
    get "/db/#{db.id}"
    expect(last_response.body).to include('New Db')
  end

  it 'answers 404 when asked for a non-existent db' do
    get '/db/1200438'
    expect(last_response.status).to eq(404)
  end

  it 'responds ok when asked for db/new' do
    get '/db/new'
    expect(last_response.status).to eq(200)
  end

  it 'responds ok when asked for the form to edit an existing db' do
    db = DbResource.create(name: 'Editable')
    get "/db/#{db.id}/edit"
    expect(last_response.status).to eq(200)
  end

  it 'responds 404 when asked for the form to edit an absent db' do
    get '/db/9884093/edit'
    expect(last_response.status).to eq(404)
  end

  it 'allows us to create a new db, then redirects to the list' do
    post '/dbs', name: "I'm new!"

    db = DbResource[name: "I'm new!"]
    expect(db).to exist
    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_request.path).to eq("/db/#{db.id}")
    expect(last_response.body).to include("I'm new!")

    get "/db/#{db.id}"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("I'm new!")
  end

  it 'allows us to edit a db, then redirects to the list' do
    db = DbResource.create(name: 'Edit Me')

    edited_db = { id:       db.id,
                  name:     'Edited Node' }

    patch '/dbs', edited_db

    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_response.status).to eq(200)
    expect(last_request.path).to eq("/db/#{db.id}")
    expect(last_response.body).to include('Edited Node')
  end

  it 'allows us to edit a single db field then redirects to the list' do
    db = DbResource.create(name: 'Edit Type', type: 'Boring')

    edited_db = { id: db.id, type: 'Not Boring!' }

    patch '/dbs', edited_db

    expect(DbResource[name: 'Edit Type'].type).to eq('Not Boring!')

    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_request.path).to eq("/db/#{db.id}")
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('Not Boring!')
  end

  it 'cannot create a db with a non-unique name' do
    db1 = DbResource.create(name: 'db1')

    expect(db1).to exist

    expect do
      DbResource.create(name: 'db1')
    end.to raise_error(StandardError)
  end
end
