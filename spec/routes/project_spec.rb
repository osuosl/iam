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
end
