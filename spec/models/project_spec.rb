require File.expand_path '../../spec_helper.rb', __FILE__

describe 'The Project Model and table' do
  def app
    Iam
  end

  include Rack::Test::Methods

  it 'initially has no projects' do
    expect(Project.all).to be_empty
  end

  it 'has a model name' do
    expect(Project.name).to eq('Project')
  end

  it 'can create a project' do
    project = Project.create(name: 'Testo')
    expect(project).to exist
  end

  it 'cannot create two projects with the same name' do
    # create a project
    Project.create(name: 'Testo')
    # expect creating another with the same name to give us a constraint
    # violation
    expect do
      Project.create(name: 'Testo')
    end.to raise_error(Sequel::UniqueConstraintViolation)
  end

  it 'can create two projects with different names' do
    # create a project
    Project.create(name: 'Testo')
    # expect it to create another with a different name
    expect { Project.create(name: 'Testo2') }.to_not raise_error
  end

  it 'cannot create a project without required fields' do
    # TODO: for models with many required fields, loop over those
    # fields and test each raised error
    expect do
      Project.create
    end.to raise_error(Sequel::ValidationFailed, /name cannot be empty/)
  end

  it 'can delete a project' do
    project = Project.create(name: 'Delete Me')
    expect(project).to exist
    expect { project.delete }.to_not raise_error
    expect(project.exists?).to be false
  end

  it 'can update a project' do
    project = Project.create(name: 'Testo', resources: 'node')
    expect(project).to exist
    expect(project.resources).to eq('node')
    expect(project.name).to eq('Testo')
    expect { project.update(resources: 'ftp,node') }.to_not raise_error
    expect(project.resources).to eq('ftp,node')
  end

  it 'cannot update a project to have a non-unique name' do
    project1 = Project.create(name: 'Testo')
    project2 = Project.create(name: 'Testo 2')

    expect(project1).to exist
    expect(project2).to exist

    expect(project1.name).to eq('Testo')
    expect(project2.name).to eq('Testo 2')

    expect do
      project2.update(name: 'Testo')
    end.to raise_error(Sequel::UniqueConstraintViolation)

    # weirdly, project2 can still be in memory with the 'updated' name
    # so refresh the model and see what it has stored
    project2.refresh
    expect(project2.name).to eq('Testo 2')
  end
end
