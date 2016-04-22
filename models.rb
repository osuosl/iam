# if we are in test mode, run the migrations first to make sure
# the test db is all set up
if ENV['RACK_ENV'] == 'test'
    Sequel::Migrator.run(Iam.settings.DB, "migrations")
end

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
