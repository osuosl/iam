# frozen_string_literal: true
require_relative '../spec_helper.rb'

describe 'The NodeResource endpoint' do
  def app
    Iam
  end

  include Rack::Test::Methods

  before(:all) do
    # anything that should happen before all tests
  end

  it 'responds OK' do
    get '/nodes'
    expect(last_response).to be_ok
    get '/nodes/'
    expect(last_response).to be_ok
  end

  it 'includes the names of existing nodes' do
    FactoryGirl.create(:node, name: 'Node X')
    FactoryGirl.create(:node, name: 'Node Y')
    FactoryGirl.create(:node, name: 'Node Z')

    get 'nodes'

    expect(last_response.body).to include('Node X')
    expect(last_response.body).to include('Node Y')
    expect(last_response.body).to include('Node Z')
  end

  it 'displays a specific Node by id' do
    node = NodeResource.create(name: 'New Node')
    get "/node/#{node.id}"
    expect(last_response.body).to include('New Node')
  end

  it 'answers 404 when asked for a non-existent node' do
    get '/node/1200438'
    expect(last_response.status).to eq(404)
  end

  it 'responds ok when asked for node/new' do
    get '/node/new'
    expect(last_response.status).to eq(200)
  end

  it 'responds ok when asked for the form to edit an existing node' do
    project = Project.create(name: 'edit')
    node = NodeResource.create(name: 'Editable', project_id: project.id)
    sku = Sku.create(name: 'edit')
    NodeResourcesProject.create(project_id: project.id,
                                node_resource_id: node.id,
                                sku_id: sku.id)

    get "/node/#{node.id}/edit"
    expect(last_response.status).to eq(200)
  end

  it 'responds 404 when asked for the form to edit an absent node' do
    get '/node/9884093/edit'
    expect(last_response.status).to eq(404)
  end

  it 'allows us to create a new node, then redirects to the list' do
    post '/nodes', name: "I'm new!"

    node = NodeResource[name: "I'm new!"]
    expect(node).to exist
    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_request.path).to eq("/node/#{node.id}")
    expect(last_response.body).to include("I'm new!")

    get "/node/#{node.id}"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("I'm new!")
  end

  it 'allows us to edit a node, then redirects to the list' do
    node = NodeResource.create(name: 'Edit Me')
    project = Project.create(name: 'First Project')
    project2 = Project.create(name: 'Second Project')
    sku = Sku.create(name: 'Edit S')
    NodeResourcesProject.create(project_id: project.id,
                                node_resource_id: node.id,
                                sku_id: sku.id)

    edited_node = { id:         node.id,
                    project_id: project.id,
                    name:       'Edited Node',
                    type:       node.type,
                    cluster:    node.cluster,
                    sku_id:     sku.id }

    patch '/nodes', edited_node

    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_response.status).to eq(200)
    expect(last_request.path).to eq("/node/#{node.id}")
    expect(last_response.body).to include('Edited Node')
  end

  it 'allows us to edit a single node field then redirects to the list' do
    node = NodeResource.create(name: 'Edit Type', type: 'Boring')
    project = Project.create(name: 'Edit P')
    sku = Sku.create(name: 'Edit S')
    NodeResourcesProject.create(project_id: project.id,
                                node_resource_id: node.id,
                                sku_id: sku.id)

    edited_node = { id: node.id, type: 'Not Boring!' }

    patch '/nodes', edited_node

    expect(NodeResource[name: 'Edit Type'].type).to eq('Not Boring!')

    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_request.path).to eq("/node/#{node.id}")
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('Not Boring!')
  end

  it 'cannot create a node with a non-unique name' do
    node1 = NodeResource.create(name: 'node1')

    expect(node1).to exist

    expect do
      Node.create(name: 'node1')
    end.to raise_error(StandardError)
  end

  it 'allows us to set a node to inactive, redirects to the list' do
    node = NodeResource.create(name: 'Edit Type', type: 'Delete Me')

    inactive_node = { id: node.id,
                      name: node.name,
                      active: false }

    delete "/nodes/#{node.id}", inactive_node
    expect(last_request.path).to eq("/nodes/#{node.id}")
    expect(last_response.status).to eq(302)
  end
end
