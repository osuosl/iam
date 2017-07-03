# frozen_string_literal: true
require 'fileutils'
require_relative '../environment.rb'
require_relative '../models.rb'
require_relative './util.rb'

###
# DataImporter - methods for sampling production data for use in testing
###
class DataImporter
  def initialize
    @directory = 'test_data/'
    @date_offset = nil
  end

  # Deletes all the extant data. This does not drop tables, only removes rows
  # rubocop:disable AbcSize
  def delete_data
    # deletes everything
    Report.plugin_matrix.each do |resource_name, measurements|
      model = Object.const_get((resource_name + 'Resource').camelcase(:upper))
      model.dataset.all.each(&:delete)

      measurements.each do |measurement_name|
        table = Plugin.where(name: measurement_name).first.storage_table
        Iam.settings.DB[table.to_sym].delete
      end
    end

    Iam.settings.DB[:projects].delete
    Iam.settings.DB[:clients].delete
  end

  def collect_objects
    json_content = [File.open(@directory + 'clients.json', &:readline),
                    File.open(@directory + 'projects.json', &:readline)]

    Report.plugin_matrix.each do |resource_name, measurements|
      filename = @directory + resource_name + '.json'
      json_content.push JSON.parse(File.open(filename, &:readline))

      measurements.each do |name|
        filename = Plugin.where(name: name).first.storage_table + '.json'
        json_content.push File.open(@directory + filename, &:readline)
      end
    end
  end

  # Find the latest date in the information to import
  def date_offset
    latest_date = nil
    collect_objects.each do |file|
      JSON.parse file .each do |object|
        object.each do |_key, value|
          next unless value.is_a?(DateTime)
          latest_date = value if !latest_date || value > latest_date
        end
      end
    end

    @date_offset = Date.today - latest_date
  end

  # Imports the clients from clients.json
  def import_clients
    # get clients from file, import to Client model
    clients_filename = @directory + 'clients.json'
    clients_json = File.open(clients_filename, &:readline)

    conditioned_json = JSON.parse(clients_json).each do |obj|
      obj.each do |key, value|
        obj[key] += @date_offset if value.is_a?(DateTime)
      end
    end

    clients = Client.array_from_json(conditioned_json.to_str,
                                     fields: Client.columns.map(&:to_s))

    clients.each(&:save)
  end

  # Imports the projects from projects.json
  def import_projects
    # get projects
    projects_filename = @directory + 'projects.json'
    projects_json = File.open(projects_filename, &:readline)

    conditioned_json = JSON.parse(projects_json).each do |obj|
      obj.each do |key, value|
        obj[key] += @date_offset if value.is_a?(DateTime)
      end
    end

    projects = Project.array_from_json(conditioned_json.to_str,
                                       fields: Project.columns.map(&:to_s))

    projects.each(&:save)
  end

  # Loop through our defined resources and import the data for each one
  # rubocop:disable MethodLength
  def import_resources
    # for each resource type, look for a file  of measurement data
    Report.plugin_matrix.each do |resource_name, measurements|
      filename = @directory + resource_name + '.json'
      resource_json = File.open(filename, &:readline)

      conditioned_json = JSON.parse(resource_json).each do |obj|
        obj.each do |key, value|
          obj[key] += @date_offset if value.is_a?(DateTime)
        end
      end

      model = Object.const_get((resource_name + 'Resource').camelcase(:upper))
      resources = model.array_from_json(conditioned_json.to_str,
                                        fields: model.columns.map(&:to_s))

      resources.each(&:save)
      measurements.each do |measurement_name|
        table = Plugin.where(name: measurement_name).first.storage_table
        filename = @directory + table + '.json'
        measurement_data = File.open(filename, &:readline)

        conditioned_json = JSON.parse(measurement_data).each do |obj|
          obj.each do |key, value|
            obj[key] += @date_offset if value.is_a?(DateTime)
          end
        end

        Iam.settings.DB[table.to_sym].multi_insert(conditioned_json)
      end
    end
  end

  # Main data importer method, calls other import methods and re-creates the
  # default client and project
  def import_data
    # delete all the things, for simplicity
    delete_data

    get_date_offset

    import_clients
    import_projects

    # re-create the default client and project
    default_client = Client.find_or_create(name: 'default',
                                           description: 'The default client')

    Project.find_or_create(name: 'default',
                           client_id: default_client.id,
                           description: 'The default project')
    # import the resources
    import_resources
  end
end

# methods for exporting data
class DataExporter
  def initialize
    @directory = 'test_data/'
    FileUtils.mkdir_p @directory
  end

  # Generate a string of random letters of <number> length
  def random_name(number)
    charset = Array('a'..'z')
    Array.new(number) { charset.sample }.join
  end

  # Change any identifying fields in the client data before export
  def anonymize_clients(clients)
    clients.each do |client|
      client[:name] = 'Client ' + random_name(3).capitalize
      client[:contact_name] = 'Fred ' + random_name(6).capitalize
      client[:contact_email] = random_name(5) + '@example.com'
      client[:description] = 'A Client Description'
    end
  end

  # Change any identifying fields in the project data before export
  def anonymize_projects(all_projects)
    all_projects.each do |project|
      # anonymize the project
      project[:name] = 'The ' + random_name(4).capitalize + ' Project'
      project[:description] = 'A description of the project'
    end
  end

  # Change any identifying fields in the resource data before export
  def anonymize_resources(resources, resource_name)
    # resources tend to have a resource-specific reference to an internal
    # server, lets try to find them and anonymize with our best guess of
    # what they will be named
    server_refs = [:ip, :server, :cluster, :fqdn, :hostname, :directory]

    resources.each do |resource|
      resource[:name] = random_name(8)
      server_refs.each do |ref|
        resource[ref] = resource_name + '.example.com' if resource.key?(ref)
      end
    end
  end

  # export the data
  def export_data(client_list: ['all'], days: 60, anon: true)
    # a time object representing the date 60 days ago
    timeframe = Time.now - (days * 86_400)

    # get the client list, write it out to a file in json format
    clients = if client_list == ['all']
                Client.where(active: true)
              else
                Client.where(id: client_list, active: true)
              end

    # for each client, get its projects, keep track of all the project ids
    project_ids = []
    clients.each do |client|
      projects = client.projects_dataset
      projects.each do |project|
        project_ids << project.id
      end
    end

    # Don't think about naked clients.
    clients = clients.naked.all
    anonymize_clients(clients) if anon

    filename = @directory + 'clients.json'
    File.open(filename, 'w') { |file| file.write(clients.to_json) }

    all_projects = Project.where(id: project_ids).naked.all
    anonymize_projects(all_projects) if anon

    # write the projects to a file in json fromat
    filename = @directory + 'projects.json'
    File.open(filename, 'w') { |file| file.write(all_projects.to_json) }

    # get all the resources of each type for each project
    Report.plugin_matrix.each do |resource_name, measurements|
      filename = @directory + resource_name + '.json'
      table = resource_name + '_resources'
      resources = Iam.settings.DB[table.to_sym].where(project_id: project_ids)

      # get an array of the resource ids
      resource_ids = resources.map(:id)
      resources = resources.naked.all
      anonymize_resources(resources, resource_name) if anon

      # write the resources to a file in json format
      File.open(filename, 'w') { |file| file.write(resources.to_json) }

      # for each measurment (plugin) available for this resource type,
      # fetch all the measurment data for the specific resource ids collected
      # above. Get all data newer than (today - TIMEFRAME)
      measurements.each do |plugin_name|
        table = Plugin.where(name: plugin_name).first.storage_table
        resource = resource_name + '_resource'
        filename = @directory + table + '.json'
        data = Iam.settings.DB[table.to_sym].where(
          resource.to_sym => resource_ids
        )
        data = data.filter { created > timeframe }.naked.all

        # Change any identifying fields in the measurement data before export
        if anon
          data.each do |datum|
            # get the new resource name
            res = resources.find { |x| x[:id] == datum[resource.to_sym] }
            datum[resource_name.to_sym] = res[:name]
          end
        end

        json = data.to_json
        File.open(filename, 'w') { |file| file.write(json) }
      end
    end
  end
end
