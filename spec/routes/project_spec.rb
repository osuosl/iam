# frozen_string_literal: true
require_relative '../spec_helper.rb'

describe 'The Projects endpoint' do
  def app
    Iam
  end

  include Rack::Test::Methods

  before(:all) do
    # anything that should happen before all tests
  end

  it 'responds OK' do
    get '/projects'
    expect(last_response).to be_ok
    get '/projects/'
    expect(last_response).to be_ok
  end

  it 'verifies the default project exists' do
    project = Project.find(name: 'default')
    expect(project).to exist
    get "/projects/#{project.id}"
    expect(last_response.status).to eq(200)
  end

  it 'includes the names of existing projects' do
    FactoryGirl.create(:project, name: 'Project X')
    FactoryGirl.create(:project, name: 'Project Y')
    FactoryGirl.create(:project, name: 'Project Z')

    get 'projects'

    expect(last_response.body).to include('Project X')
    expect(last_response.body).to include('Project Y')
    expect(last_response.body).to include('Project Z')
  end

  it 'displays a specific project by id' do
    client = Client.find(name: 'default')
    project = Project.create(name: 'New Project', client_id: client.id)
    get "/projects/#{project.id}"
    expect(last_response.body).to include('New Project')
  end

  it 'answers 404 when asked for a non-existent project' do
    get '/projects/1200438'
    expect(last_response.status).to eq(404)
  end

  it 'responds ok when asked for projects/new' do
    get '/projects/new'
    expect(last_response.status).to eq(200)
  end

  it 'responds ok when asked for the form to edit an existing project' do
    project = Project.create(name: 'Editable')
    get "/projects/#{project.id}/edit"
    expect(last_response.status).to eq(200)
  end

  it 'responds 404 when asked for the form to edit an absent project' do
    get '/projects/9884093/edit'
    expect(last_response.status).to eq(404)
  end

  it 'allows us to create a new project, then redirects to the list' do
    client = Client.find(name: 'default')
    post '/projects', name: 'im new', client_id: client.id

    project = Project[name: 'im new']
    expect(project).to exist
    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_request.path).to eq("/projects/#{project.id}")
    expect(last_response.body).to include('im new')

    get "/projects/#{project.id}"
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('im new')
  end

  it 'allows us to edit a project, then redirects to the list' do
    client = Client.find(name: 'default')
    project = Project.create(name: 'Edit Me', client_id: client.id)

    edited_project = { id: project.id,
                       name: 'Edited Project',
                       client_id: project.client_id }

    patch '/projects', edited_project

    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_response.status).to eq(200)
    expect(last_request.path).to eq("/projects/#{project.id}")
    expect(last_response.body).to include('Edited Project')
  end

  it 'allows us to edit a single project field then redirects to the list' do
    client = Client.find(name: 'default')
    project = Project.create(name: 'Edit Description', description: 'unedited',
                             client_id: client.id)
    edited_project = { id: project.id, description: 'i edited this' }

    patch '/projects', edited_project

    expect(Project[name: 'Edit Description'].description).to eq('i edited this')

    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_request.path).to eq("/projects/#{project.id}")
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('i edited this')
  end

  it 'cannot create a client with a non-unique name' do
    project1 = Project.create(name: 'project1')

    expect(project1).to exist

    expect do
      Project.create(name: 'project1')
    end.to raise_error(StandardError)
  end
  it 'allows us to delete a project with no nodes/db, redirects to the list' do
    project = Project.create(name: 'Delete me', active: true)

    deleted_project = { id: project.id,
                        name: project.name,
                        active: false }

    delete "/projects/#{project.id}", deleted_project
    expect(last_request.path).to eq("/projects/#{project.id}")
    expect(last_response.status).to eq(302)
  end

  it 'allows us to delete a project with nodes/db, redirects to the list' do
    project = Project.create(name: 'Delete me', active: true)
    sku = Sku.create(name: 'Delete sku')
    node = NodeResource.create(name: 'Delete Node', project_id: project.id)
    np = NodeResourcesProject.create(project_id: project.id,
                                     node_resource_id: node.id,
                                     sku_id: sku.id)
    db = DbResource.create(name: 'Delete Db', project_id: project.id)
    dbp = DbResourcesProject.create(project_id: project.id,
                                    db_resource_id: db.id,
                                    sku_id: sku.id)

    deleted_project = { id: project.id,
                        name: project.name,
                        active: false }

    delete "/projects/#{project.id}", deleted_project
    expect(last_request.path).to eq("/projects/#{project.id}")
    expect(last_response.status).to eq(302)

    get "node/#{node.id}"
    expect(last_response.status).to eq(200)
    get "db/#{db.id}"
    expect(last_response.status).to eq(200)
  end
end
