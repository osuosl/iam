FactoryGirl.define do
  # use sequences to dynamically create unique records on demand

  # Clients
  sequence :email do |n|
    "sarah#{n}@example.com"
  end

  sequence :contact_name do |n|
    "Sarah #{n}"
  end

  sequence :client_name do |n|
    "Client number #{n}"
  end

  # Projects
  sequence :project_name do |n|
    "Project number #{n}"
  end

  # NodeResource
  sequence :node_name do |n|
    "Node number #{n}"
  end

  factory :client, class: Client do
    # this lets factory girl save Sequel models
    to_create(&:save)
    name          { generate(:client_name) }
    contact_name  { generate(:contact_name) }
    contact_email { generate(:email) }
    description   'An important client'
  end

  factory :project, class: Project do
    to_create(&:save)
    name        { generate(:project_name) }
    resources   'node,ftp'
    description 'An important project'
  end

  factory :node, class: NodeResource do
    to_create(&:save)
    name        { generate(:node_name) }
    type        'VM'
    cluster     'Ganetti'
  end
end
