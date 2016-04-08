
# Require base
require 'sinatra/base'
require 'rubygems'
require 'sequel'
require 'sqlite3'

DB = Sequel.sqlite('dev.db')


## create the tables

# Core tables


DB.create_table? :clients do
  primary_key :id
  String      :name,          :unique => true
  String      :contact_name
  String      :contact_email
  String      :description,   :text=>true

end

DB.create_table? :projects do
  primary_key :id
  foreign_key :client_id,   :clients
  String      :name,        :unique => true
  String      :resources,   :size => 255
  String      :description, :text=>true
end

DB.create_table? :plugins do
  primary_key :id
  String      :name,      :unique => true
  String      :resource_type
  String      :storage_table
  String      :units
end


# Resource tables

DB.create_table? :node_resources do
  primary_key :id
  foreign_key :project_id,  :projects
  String      :name,        :unique => true # an fqdn in this case
  String      :type # ganeti, openstack, hardware
  String      :cluster
  DateTime    :created
  DateTime    :modified
end

DB.create_table? :network_resources do
  primary_key :id
  foreign_key :project_id,  :projects
  String      :name,        :unique => true # an ip or ip range
  String      :type # ipv4, ipv6, vip?
  DateTime    :created
  DateTime    :modified
end

DB.create_table? :time_resources do
  primary_key :id
  foreign_key :project_id,  :projects
  String      :name,        :unique => true #arbitrary
  String      :type # maybe we only bill a specific activity?
  DateTime    :created
  DateTime    :modified
end

DB.create_table? :ftp_resources do
  primary_key :id
  foreign_key :project_id,  :projects
  String      :name,        :unique => true # directory
  String      :type # possibly no use for this
  DateTime    :created
  DateTime    :modified
end


## the Models

class Client < Sequel::Model
  one_to_many :projects
end

class Project < Sequel::Model
  many_to_one :client
end

class Plugin < Sequel::Model
  
end

# Resource models - let's assume these are a pretty complete list
# of resources types a project can have

class NodeResource < Sequel::Model
  many_to_many  :projects
end

class NetworkResource < Sequel::Model
  many_to_many  :projects
end

class FtpResource < Sequel::Model
  many_to_many  :projects
end

class TimeResource < Sequel::Model
  many_to_many  :projects
end
