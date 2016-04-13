require 'sequel'

db = Sequel.connect(ENV.fetch('DATABASE_URL'))

class Client < Sequel::Model
  one_to_many :projects
end

class Project < Sequel::Model
  many_to_one :client
end

class Plugin < Sequel::Model

end

class NodeResource < Sequel::Model
  many_to_many :projects
end
