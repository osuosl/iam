# frozen_string_literal: true
# if we are in test mode, run the migrations first to make sure
# the test db is all set up
Sequel::Migrator.run(Iam.settings.DB, 'migrations') if ENV['RACK_ENV'] == 'test'
Sequel::Model.plugin :json_serializer

# Client data model
# Client has many Projects
# String    :name,          :unique => true
# String    :contact_name
# String    :contact_email
# String    :description,   :text => true
# Boolean     :active, default: true
class Client < Sequel::Model
  one_to_many :projects
  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
  end

  def remove
    projects.each(&:reassign_resources) unless projects.empty?
    delete
  end
end

# Project data model
# Project has one client
# String    :name,        :unique => true
# String    :resources,   :size => 255
# String    :description, :text => true
# Boolean     :active, default: true
class Project < Sequel::Model
  many_to_one :client

  one_to_many :node_resources_projects
  one_to_many :node_resources, join_table: :node_resources_projects

  one_to_many :db_resources_projects
  one_to_many :db_resources, join_table: :db_resources_projects
  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
  end

  def reassign_resources
    Report.plugin_matrix.each do |resource_type, _measurements|
      data = send("#{resource_type}_resources")
      next if data.empty?
      # reassign the projects' resources to the default project
      data.each do |resource|
        resource.update(project_id: Project.find(name: 'default').id)
      end
    end
    delete
  end
end

# Plugin data model
# String    :name,        :unique => true
# String    :resource_name
# String    :storage_table
# String    :units
# Boolean     :active, default: true
class Plugin < Sequel::Model
  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
  end
end

# Node Resource data model
# A Node belongs to one Project
# Projects may own many Nodes
# String    :name,        :unique => true
# String    :type
# String    :cluster
# DateTime  :created
# DateTime  :modified
# Boolean     :active, default: true
class NodeResource < Sequel::Model
  many_to_one :project
  one_to_one :node_resources_projects
  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
  end

  def reassign_resources
    NodeResourcesProject.where(node_resource_id: id).delete
    update(active: false)
  end
end

# Project-Node Resource data model
# A Project-Node belongs to one Project
# Projects may own many Project-Nodes
# Integer    :project_id
# Integer    :node_id
class NodeResourcesProject < Sequel::Model
  many_to_one :project
  one_to_one :node_resource
  one_to_one :skus
end

# Database Resource data model
# A Database belongs to one Project
# Projects may own many Databases
# String    :name,        :unique => true
# String    :type
# String    :server
# DateTime  :created
# DateTime  :modified
# Boolean     :active, default: true
class DbResource < Sequel::Model
  many_to_one :project
  one_to_one :db_resources_projects
  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
  end

  def reassign_resources
    DbResourcesProject.where(db_resource_id: id).delete
    update(active: false)
  end
end

# Project-Node Resource data model
# A Project-Node belongs to one Project
# Projects may own many Project-Nodes
# Integer    :project_id
# Integer    :node_id
class DbResourcesProject < Sequel::Model
  many_to_one :project
  one_to_one :db_resource
  one_to_one :skus
end

# Collector stats data model
# String    :name
# DateTime  :created
# Time      :start
# Time      :end
# Boolean   :success
class CollectorStat < Sequel::Model
  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
  end
end

# SKU stats data model
# primary_key :id
# String      :family
# String      :sku_num
# String      :description
# Float       :rate
# Boolean     :active, default: true
class Sku < Sequel::Model
  one_to_one :node_resources_projects
  one_to_one :db_resources_projects
  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
  end

  def reassign_resources
    DbResourcesProject.where(sku_id: id).delete
    NodeResourcesProject.where(sku_id: id).delete
    delete
  end
end
