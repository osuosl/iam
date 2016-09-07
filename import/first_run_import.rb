#
# this file will import the csv data to the DB from the CSV only ONCE
#
require_relative '../environment.rb'
require_relative '../models.rb'

# if clients table is empty, import data
clients_exist = Iam.settings.DB[:clients].first
already_ran = false
already_ran = true if clients_exist
unless already_ran
  puts 'Running first run import!'
  require 'csv'

  file = 'import/initial_clients.csv'
  data = CSV.read(file, headers: true)
  data.each do |row|
    # puts row['client'] + ', ' + row['project'] + ', ' + row['fqdn']
    # find or create client
    new_client = Client.find_or_create(name: row['client'],
                                       contact_name: 'bob',
                                       contact_email: 'bob@example.com',
                                       description: 'bob loblaw')
    # find or create project
    new_project = Project.find_or_create(name: row['project'],
                                         client_id: new_client.id)
    # find or create node
    NodeResource.find_or_create(name: row['fqdn'],
                                project_id: new_project.id,
                                type: 'ganeti',
                                cluster: 'cluster1.osuosl.org')
  end
  puts 'Finished running first run import'
end
