# if we are in test mode, run the migrations first to make sure
# the test db is all set up
Sequel::Migrator.run(Iam.settings.DB, 'migrations') if ENV['RACK_ENV'] == 'test'

# Client data model
# Client has many Projects
# String    :name,          :unique => true
# String    :contact_name
# String    :contact_email
# String    :description,   :text => true
class Client < Sequel::Model
  one_to_many :projects
end

# Project data model
# Project has one client
# String    :name,        :unique => true
# String    :resources,   :size => 255
# String    :description, :text => true
class Project < Sequel::Model
  many_to_one :client
end

# Plugin data model
# String    :name,        :unique => true
# String    :resource_name
# String    :storage_table
# String    :units
class Plugin < Sequel::Model
end

# Node Resource data model
# A Node belongs to one Project
# Projects may own many Nodes
# String    :name,        :unique => true
# String    :type
# String    :cluster
# DateTime  :created
# DateTime  :modified
class NodeResource < Sequel::Model
  many_to_one :projects
end
