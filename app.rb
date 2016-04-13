# myapp.rb
require 'sinatra'

# Include database models.
# Run `rake migrations` to create the database.
require_relative 'models'

class Iam < Sinatra::Base
  DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

  o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten

  name = (0...10).map { o[rand(o.length)] }.join
  new_client = Client.create(:name          => name,
                             :contact_name  => 'bob',
                             :contact_email => 'bob@example.com',
                             :description   => 'blah')

  name = (0...10).map { o[rand(o.length)] }.join
  new_project = Project.create(:name        => name,
                               :client_id   => new_client.id,
                               :resources   => 'node, thingy',
                               :description => 'blah')

  name = (0...10).map { o[rand(o.length)] }.join
  new_code = NodeResource.create(:project_id => new_project.id,
                                  :name       => name,
                                  :type       => 'ganeti',
                                  :cluster    => 'cluster1.osuosl.org',
                                  :created    => DateTime.now,
                                  :modified   => DateTime.now)

  print "Clients:"
  for client in Client.all do
    puts client.name
  end

  print "Projects:"
  for project in Project.all do
    puts project.name
  end

  print "NodeResources:"
  for node_resource in NodeResource.all do
    puts node_resource.name
  end

  print "Plugins:"
  for plugin in Plugin.all do
    puts plugin.name
  end

end
