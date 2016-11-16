# if we are in test mode, run the migrations first to make sure
# the test db is all set up
Sequel::Migrator.run(Iam.settings.DB, 'migrations') if ENV['RACK_ENV'] == 'test'

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
end

# Project data model
# Project has one client
# String    :name,        :unique => true
# String    :resources,   :size => 255
# String    :description, :text => true
# Boolean     :active, default: true
class Project < Sequel::Model
  many_to_one :client
  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
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
  many_to_one :projects
  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
  end
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
class DBResource < Sequel::Model
  many_to_one :projects
  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
  end
end
