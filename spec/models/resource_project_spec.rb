# frozen_string_literal: true
require File.expand_path '../../spec_helper.rb', __FILE__

describe 'The Db and Node Projects Model and table' do
  def app
    Iam
  end
  include Rack::Test::Methods

  it 'can access a node resource using project.node_resource' do
    project = Project.create(name: 'Test')
    node = NodeResource.create(name: 'Node Test', project_id: project.id)

    expect(project.node_resources).to eq([node])
  end

  it 'can access a db resource using project.db_resource' do
    project = Project.create(name: 'Test')
    db = DbResource.create(name: 'DB Test', project_id: project.id)

    expect(project.db_resources).to eq([db])
  end

  it 'can access a project and node id using node_resources_projects' do
    project = Project.create(name: 'Test')
    node = NodeResource.create(name: 'Node Test', project_id: project.id)
    resource_project = NodeResourcesProject.create(project_id: project.id,
                                                   node_resource_id: node.id)

    expect(resource_project).to exist
    expect(resource_project.project_id).to eq(2)
    expect(resource_project.node_resource_id).to eq(1)
  end

  it 'can access a project and db id using db_resources_projects' do
    project = Project.create(name: 'Test')
    db = DbResource.create(name: 'Db Test', project_id: project.id)
    resource_project = DbResourcesProject.create(project_id: project.id,
                                                 db_resource_id: db.id)

    expect(resource_project).to exist
    expect(resource_project.project_id).to eq(2)
    expect(resource_project.db_resource_id).to eq(1)
  end
end
