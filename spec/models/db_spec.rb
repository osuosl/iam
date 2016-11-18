require File.expand_path '../../spec_helper.rb', __FILE__

describe 'The DBResource Model and table' do
  def app
    Iam
  end

  include Rack::Test::Methods

  it 'initially has one DBResource (the default DBResource)' do
    expect(DBResource.count).to be(1)
  end

  it 'has a model name' do
    expect(DBResource.name).to eq('DBResource')
  end

  it 'can create a db' do
    db = DBResource.create(name: 'Testo')
    expect(db).to exist
  end

  it 'cannot create two dbs with the same name' do
    # create a database
    DBResource.create(name: 'Testo')
    # expect creating another with the same name to give us a constraint
    # violation
    expect do
      DBResource.create(name: 'Testo')
    end.to raise_error(Sequel::UniqueConstraintViolation)
  end

  it 'can create two dbs with different names' do
    # create a database
    DBResource.create(name: 'Testo')
    # expect it to create another with a different name
    expect { DBResource.create(name: 'Testo2') }.to_not raise_error
  end

  it 'cannot create a db without required fields' do
    # TODO: for models with many required fields, loop over those
    # fields and test each raised error
    expect do
      DBResource.create
    end.to raise_error(Sequel::ValidationFailed, /name cannot be empty/)
  end

  it 'can delete a db' do
    db = DBResource.create(name: 'Delete Me')
    expect(db).to exist
    expect { db.delete }.to_not raise_error
    expect(db).to_not exist
  end

  it 'can update a db' do
    db = DBResource.create(name: 'Testo', type: 'mysql')
    expect(db).to exist
    expect(db.type).to eq('mysql')
    expect(db.name).to eq('Testo')
    expect { db.update(type: 'ohai') }.to_not raise_error
    expect(db.type).to eq('ohai')
  end

  it 'cannot update a db to have a non-unique name' do
    db1 = DBResource.create(name: 'Testo')
    db2 = DBResource.create(name: 'Testo 2')

    expect(db1).to exist
    expect(db2).to exist

    expect(db1.name).to eq('Testo')
    expect(db2.name).to eq('Testo 2')

    expect do
      db2.update(name: 'Testo')
    end.to raise_error(Sequel::UniqueConstraintViolation)
  end

  it 'has an active flag' do
    db = DBResource.create(name: 'testo')

    expect(db).to exist
    expect(db.active).to eq(true)
  end

  it 'changing the active flag does not result in an error' do
    db = DBResource.create(name: 'testo')

    expect(db).to exist
    expect(db.active).to eq(true)
    expect { db.update(active: false) }.to_not raise_error
    expect { db.update(active: true) }.to_not raise_error
  end
end
