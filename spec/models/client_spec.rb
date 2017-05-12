# frozen_string_literal: true
require File.expand_path '../../spec_helper.rb', __FILE__

describe 'The Client Model and table' do
  def app
    Iam
  end

  include Rack::Test::Methods

  it 'initially has only one client (the default client)' do
    expect(Client.count).to be(1)
  end

  it 'has a model name' do
    expect(Client.name).to eq('Client')
  end

  it 'can create a client' do
    client = Client.create(name: 'Testo')
    expect(client).to exist
  end

  it 'cannot create two clients with the same name' do
    # create a client
    Client.create(name: 'Testo')
    # expect creating another with the same name to give us a constraint
    # violation
    expect do
      Client.create(name: 'Testo')
    end.to raise_error(Sequel::UniqueConstraintViolation)
  end

  it 'can create two clients with different names' do
    # create a client
    Client.create(name: 'Testo')
    # expect it to create another with a different name
    expect { Client.create(name: 'Testo2') }.to_not raise_error
  end

  it 'cannot create a client without required fields' do
    # TODO: for models with many required fields, loop over those
    # fields and test each raised error
    expect do
      Client.create
    end.to raise_error(Sequel::ValidationFailed, /name cannot be empty/)
  end

  it 'can delete a client' do
    client = Client.create(name: 'Delete Me')
    expect(client).to exist
    expect { client.delete }.to_not raise_error
    expect(client.exists?).to be false
  end

  it 'can update a client' do
    client = Client.create(name: 'Testo', contact_name: 'Change Me')
    expect(client).to exist
    expect(client.contact_name).to eq('Change Me')
    expect(client.name).to eq('Testo')
    expect { client.update(contact_name: 'Fred') }.to_not raise_error
    expect(client.contact_name).to eq('Fred')
  end

  it 'cannot update a client to have a non-unique name' do
    client1 = Client.create(name: 'Testo')
    client2 = Client.create(name: 'Testo 2')

    expect(client1).to exist
    expect(client2).to exist

    expect(client1.name).to eq('Testo')
    expect(client2.name).to eq('Testo 2')

    expect do
      client2.update(name: 'Testo')
    end.to raise_error(Sequel::UniqueConstraintViolation)

    # weirdly, client2 can still be in memory with the 'updated' name
    # so refresh the model and see what it has stored
    client2.refresh
    expect(client2.name).to eq('Testo 2')
  end

  it 'has an active flag' do
    client = Client.create(name: 'testo')

    expect(client).to exist
    expect(client.active).to eq(true)
  end

  it 'changing the active flag does not result in an error' do
    client = Client.create(name: 'testo')

    expect(client).to exist
    expect(client.active).to eq(true)
    expect { client.update(active: false) }.to_not raise_error
    expect { client.update(active: true) }.to_not raise_error
  end
end
