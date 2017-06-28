# frozen_string_literal: true
require File.expand_path '../../spec_helper.rb', __FILE__

describe 'The NodeResource Model and table' do
  def app
    Iam
  end

  include Rack::Test::Methods

  it 'initially have only zero NodeResource' do
    expect(NodeResource.count).to be(0)
  end

  it 'has a model name' do
    expect(NodeResource.name).to eq('NodeResource')
  end

  it 'can create a node' do
    node = NodeResource.create(name: 'Testo')
    expect(node).to exist
  end

  it 'cannot create two nodes with the same name' do
    # create a node
    NodeResource.create(name: 'Testo')
    # expect creating another with the same name to give us a constraint
    # violation
    expect do
      NodeResource.create(name: 'Testo')
    end.to raise_error(Sequel::UniqueConstraintViolation)
  end

  it 'can create two nodes with different names' do
    # create a node
    NodeResource.create(name: 'Testo')
    # expect it to create another with a different name
    expect { NodeResource.create(name: 'Testo2') }.to_not raise_error
  end

  it 'cannot create a node without required fields' do
    # TODO: for models with many required fields, loop over those
    # fields and test each raised error
    expect do
      NodeResource.create
    end.to raise_error(Sequel::ValidationFailed, /name cannot be empty/)
  end

  it 'can delete a node' do
    node = NodeResource.create(name: 'Delete Me')
    expect(node).to exist
    expect { node.reassign_resources }.to_not raise_error
    expect(node.active).to be false
  end

  it 'can update a node' do
    node = NodeResource.create(name: 'Testo', type: 'ganeti')
    expect(node).to exist
    expect(node.type).to eq('ganeti')
    expect(node.name).to eq('Testo')
    expect { node.update(type: 'ohai') }.to_not raise_error
    expect(node.type).to eq('ohai')
  end

  it 'cannot update a node to have a non-unique name' do
    node1 = NodeResource.create(name: 'Testo')
    node2 = NodeResource.create(name: 'Testo 2')

    expect(node1).to exist
    expect(node2).to exist

    expect(node1.name).to eq('Testo')
    expect(node2.name).to eq('Testo 2')

    expect do
      node2.update(name: 'Testo')
    end.to raise_error(Sequel::UniqueConstraintViolation)

    # weirdly, node2 can still be in memory with the 'updated' name
    # so refresh the model and see what it has stored
    node2.refresh
    expect(node2.name).to eq('Testo 2')
  end

  it 'has an active flag' do
    node = NodeResource.create(name: 'testo')

    expect(node).to exist
    expect(node.active).to eq(true)
  end

  it 'changing the active flag does not result in an error' do
    node = NodeResource.create(name: 'testo')

    expect(node).to exist
    expect(node.active).to eq(true)
    expect { node.update(active: false) }.to_not raise_error
    expect { node.update(active: true) }.to_not raise_error
  end
end
