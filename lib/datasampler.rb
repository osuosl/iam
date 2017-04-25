require_relative '../environment.rb'
require_relative '../models.rb'
require_relative './util.rb'

###
# DataLoader - methods for sampling production data for use in testing
###
class DataSampler
  def self.load_data
    # delete all the things, for simplicity
    puts "deleting all existing data"
    plugins = Report.plugin_matrix
    plugins.each do |resource_name, measurements|
    #  filename = "test_data/" + resource_name + ".json"
      model_name = (resource_name + "Resource").camelcase(:upper)
      model = Object.const_get(model_name)
      objects = model.dataset.all
      objects.each do |object|
        puts "deleting " + object.name
        object.delete
      end
      measurements.each do |measurement_name|
        table = Plugin.where(:name => measurement_name).first.storage_table
        puts "deleting measurements from " + table
        Iam.settings.DB[table.to_sym].delete
      end
    end

    puts "deleting projects"
    Iam.settings.DB[:projects].delete
    puts "deleting clients"
    Iam.settings.DB[:clients].delete

    # get clients from file, import to Client model
    clients_filename = 'test_data/clients.json'
    puts "creating clients from " + clients_filename
    clients_json = File.open(clients_filename, &:readline)

    clients = Client.array_from_json(clients_json, :fields=>%w'id name contact_name contact_email description active')

    clients.each do |client|
      client.save
    end

    # get projects
    projects_filename = 'test_data/projects.json'
    puts "creating projects from " + projects_filename
    projects_json = File.open(projects_filename, &:readline)
    projects = Project.array_from_json(projects_json, :fields=>%w'id client_id name description active')

    projects.each do |project|
      project.save
    end

    # re-create the default client and project
    puts "re-creating the default client and project"
    default_client = Client.find_or_create(name: 'default',
                                           description: 'The default client')
    Project.find_or_create(name: 'default',
                           client_id: default_client.id,
                           description: 'The default project')
                           
    # for each resource type, look for a file  of measurement data
    plugins.each do |resource_name, measurements|
      filename = "test_data/" + resource_name + ".json"
      puts "creating " + resource_name + "s from " + filename
      resource_json = File.open(filename, &:readline)
      model_name = (resource_name + "Resource").camelcase(:upper)
      model = Object.const_get(model_name)

      # force from_json to import every field, normally 'id' is restricted
      # first, get all the column names as an array of strings
      model_columns = model.columns.map { |x| x.to_s }
      # then specify these as the fields to import
      resources = model.array_from_json(resource_json, :fields=>model_columns)
      # the resources objects aren't saved yet, just created, so save them
      resources.each do |resource|
        resource.save
      end

      measurements.each do |measurement_name|
        table = Plugin.where(:name => measurement_name).first.storage_table
        filename = 'test_data/' + table + '.json'
        puts "loading " + measurement_name + "s from " + filename
        measurement_data = JSON.parse(File.open(filename, &:readline))
        Iam.settings.DB[table.to_sym].multi_insert(measurement_data)
      end
    end
  end

  def export_data(days, clients)
    # a time object representing the date 60 days ago
    timefram = Time.now - (days * 86400)

    # get the resources available
    plugins = Report.plugin_matrix

    # get the client list, write it out to a file in json format
    clients = Client.where(:id => clients)
    File.open("test_data/clients.json", 'w') { |file| file.write(clients.naked.all.to_json) }

    project_ids = []
    plugin_names = []
    resource_names = []
    # for each client, get its projects
    clients.each do |client|
      projects = client.projects_dataset

      # collect the project ids, accumulate to the master list of all project ids
      projects.each do |project|
        project_ids << project.id
      end

      # get all the resource types by name
      plugins.each do |resource, plugins|
        resource_names << resource
      end
    end

    all_projects = Project.where(:id => project_ids)

    #write the projects to a file in json fromat
    File.open("test_data/projects.json", 'w') { |file| file.write(all_projects.naked.all.to_json) }

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
        json = data.filter{created > timeframe}.all.to_json
        File.open(filename, 'w') { |file| file.write(json) }
        #  end
      end
    end
  end
end
