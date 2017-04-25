###
# DataSampler - using a pre-defined list of client ids, fetch a set of test
# data.
#
# measurement data will be pulled for all resources owned by the projects of the
# specified clients - it's recommended to keep the client list small and include
# clients with a manageable number of resources. Resources can be arranged
# arbitrarily on the staging instance before sampling if a particular situation
# needs to be tested
#
# measurement data will be fetched for the previous two months (change
# TIMEFRAME constant to modify this)
#
# data will be written to json files, each named for the resource or model
# sampled
###

# setup the app
require_relative './environment.rb'
require_relative './models.rb'
require_relative './lib/util.rb'

# a time object representing the date 60 days ago
TIMEFRAME = Time.now - (60 * 86400)

# 4-21-17 - selected  ROS (3), Helpdesk (5), PHPBB (11), OSL (12)
CLIENT_IDS = [3,5,11,12]

# get the resources available
plugins = Report.plugin_matrix

# get the client list, write it out to a file in json format
clients = Client.where(:id => CLIENT_IDS)
File.open("test_data/clients.json", 'w') { |file| file.write(clients.naked.all.to_json) }

project_ids = []
plugin_names = []
resource_names = []
# for each client, get its projects
clients.each do |client|
  projects = client.projects_dataset

  #write the projects to a file in json fromat
  File.open("test_data/projects.json", 'w') { |file| file.write(projects.naked.all.to_json) }

  # collect the project ids, accumulate to the master list of all project ids
  projects.each do |project|
    project_ids << project.id
  end

  # get all the resource types by name
  plugins.each do |resource, plugins|
    resource_names << resource
  end
end

# get all the resources of each type for each project
plugins.each do |resource_name, measurements|
  filename = "test_data/" + resource_name + ".json"
  table = resource_name + "_resources"
  resources = Iam.settings.DB[table.to_sym].where(:project_id => project_ids)

  # write the resources to a file in json format
  File.open(filename, 'w') { |file| file.write(resources.all.to_json) }

  # get an array of the resource ids
  resource_ids = resources.map(:id)

  # for each measurment (plugin) available for this resource type, fetch all
  # the measurment data for the specific resource ids collected above. Get
  # all data newer than today - TIMEFRAME
  measurements.each do |plugin_name|
    table = Plugin.where(:name => plugin_name).first.storage_table
    resource = resource_name + "_resource"
    filename = "test_data/" + table + ".json"
    data = Iam.settings.DB[table.to_sym].where(resource.to_sym => resource_ids)
    json = data.filter{created > TIMEFRAME}.all.to_json
    File.open(filename, 'w') { |file| file.write(json) }
    #  end
  end
end
