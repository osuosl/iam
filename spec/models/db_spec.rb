# frozen_string_literal: true
require File.expand_path '../../spec_helper.rb', __FILE__

describe 'The DbResource Model and table' do
  def app
    Iam
  end

  include Rack::Test::Methods

  it 'initially has zero DBResources' do
    expect(DbResource.count).to be(0)
  end

  it 'has a model name' do
    expect(DbResource.name).to eq('DbResource')
  end

  it 'can create a db' do
    db = DbResource.create(name: 'Testo')
    expect(db).to exist
  end

  it 'cannot create two dbs with the same name' do
    # create a database
    DbResource.create(name: 'Testo')
    # expect creating another with the same name to give us a constraint
    # violation
    expect do
      DbResource.create(name: 'Testo')
    end.to raise_error(Sequel::UniqueConstraintViolation)
  end

  it 'can create two dbs with different names' do
    # create a database
    DbResource.create(name: 'Testo')
    # expect it to create another with a different name
    expect { DbResource.create(name: 'Testo2') }.to_not raise_error
  end

  it 'cannot create a db without required fields' do
    # TODO: for models with many required fields, loop over those
    # fields and test each raised error
    expect do
      DbResource.create
    end.to raise_error(Sequel::ValidationFailed, /name cannot be empty/)
  end

  it 'can delete a db' do
    db = DbResource.create(name: 'Delete Me')
    expect(db).to exist
    expect { db.reassign_resources }.to_not raise_error
    expect(db.active).to be false
  end

  it 'can update a db' do
    db = DbResource.create(name: 'Testo', type: 'mysql')
    expect(db).to exist
    expect(db.type).to eq('mysql')
    expect(db.name).to eq('Testo')
    expect { db.update(type: 'ohai') }.to_not raise_error
    expect(db.type).to eq('ohai')
  end

  it 'cannot update a db to have a non-unique name' do
    db1 = DbResource.create(name: 'Testo')
    db2 = DbResource.create(name: 'Testo 2')

    expect(db1).to exist
    expect(db2).to exist

    expect(db1.name).to eq('Testo')
    expect(db2.name).to eq('Testo 2')

    expect do
      db2.update(name: 'Testo')
    end.to raise_error(Sequel::UniqueConstraintViolation)
  end

  it 'has an active flag' do
    db = DbResource.create(name: 'testo')

    expect(db).to exist
    expect(db.active).to eq(true)
  end

  it 'changing the active flag does not result in an error' do
    db = DbResource.create(name: 'testo')

    expect(db).to exist
    expect(db.active).to eq(true)
    expect { db.update(active: false) }.to_not raise_error
    expect { db.update(active: true) }.to_not raise_error
  end
end
