# frozen_string_literal: true
require File.expand_path '../../spec_helper.rb', __FILE__

describe 'The SKU Model and table' do
  def app
    Iam
  end

  include Rack::Test::Methods

  it 'has only a default sku initially' do
    expect(Sku.count).to be(1)
  end

  it 'has a model name' do
    expect(Sku.name).to eq('Sku')
  end

  it 'creates sku with name' do
    sku = Sku.create(name: 'reallycool')
    expect(sku).to exist
  end

  # test for name
  it 'can create sku' do
    expect { Sku.create(name: 'testo') }.to_not raise_error
  end

  it 'cannot create two skus with the same name' do
    # create a Sku
    Sku.create(name: 'Testo')
    # expect creating another with the same name to give us a constraint
    # violation
    expect do
      Sku.create(name: 'Testo')
    end.to raise_error(Sequel::UniqueConstraintViolation)
  end

  it 'cannot create a sku without required fields' do
    expect do
      Sku.create
    end.to raise_error(Sequel::ValidationFailed, /name cannot be empty/)
  end

  it 'can delete a sku' do
    sku = Sku.create(name: 'Delete Me')
    expect(sku).to exist
    expect { sku.delete }.to_not raise_error
    expect(sku).to_not exist
  end

  it 'can update a sku' do
    sku = Sku.create(name: 'Testo', family: 'node')
    expect(sku).to exist
    expect(sku.family).to eq('node')
    expect(sku.name).to eq('Testo')
    expect { sku.update(family: 'ftp,node') }.to_not raise_error
    expect(sku.family).to eq('ftp,node')
  end

  it 'cannot update a sku to have a non-unique name' do
    sku1 = Sku.create(name: 'Testo')
    sku2 = Sku.create(name: 'Testo 2')

    expect(sku1).to exist
    expect(sku2).to exist

    expect(sku1.name).to eq('Testo')
    expect(sku2.name).to eq('Testo 2')

    expect do
      sku2.update(name: 'Testo')
    end.to raise_error(Sequel::UniqueConstraintViolation)

    # weirdly, sku2 can still be in memory with the 'updated' name
    # so refresh the model and see what it has stored
    sku2.refresh
    expect(sku2.name).to eq('Testo 2')
  end

  it 'can set a family, sku, description, and rate' do
    sku = Sku.create(name: 'Testo', family: 'testing', sku_num: '44')
    # checks to see if all parts of the sku model store the information
    # correctly.
    sku.update(description: 'reallycool')
    sku.update(rate: '6.8')
    expect(sku).to exist
    expect(sku.name).to eq('Testo')
    expect(sku.family).to eq('testing')
    expect(sku.sku_num).to eq(44)
    expect(sku.description).to eq('reallycool')
    expect(sku.rate).to eq(6.8)
  end
  it 'has an active flag' do
    sku = Sku.create(name: 'testo')

    expect(sku).to exist
    expect(sku.active).to eq(true)
  end

  it 'changing the active flag does not result in an error' do
    sku = Sku.create(name: 'testo')

    expect(sku).to exist
    expect(sku.active).to eq(true)
    expect { sku.update(active: false) }.to_not raise_error
    expect { sku.update(active: true) }.to_not raise_error
  end
end
