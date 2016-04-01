require 'rubygems'
require 'bundler'

# Setup load paths 
Bundler.require
$: << File.expand_path('../', __FILE__)

# Require base (this gives us access to Sintra)
require 'sinatra/base'

# require our core models 
require 'models'

# require all the plugins dynamically - each must be a self-contained ruby file
Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each {|file| require file }

# now we have access to all the core models, and all the plugin classes
# define the app

class Iam < Sinatra::Base

  # lets make some new example objects - names are unique, so make those random
  o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
  name = (0...10).map { o[rand(o.length)] }.join

  new_client = Client.create(:name => name, 
                             :contact_name => 'bob', 
                             :contact_email => 'bob@example.com', 
                             :description => 'blah')

  name = (0...10).map { o[rand(o.length)] }.join

  new_project =  Project.create(:name => name, 
                                :client_id => new_client.id, 
                                :resources => 'node,thingy', 
                                :description => 'blah')

  name = (0...10).map { o[rand(o.length)] }.join

  new_node = NodeResource.create(:project_id => new_project.id, 
                                 :name => name, 
                                 :type => 'ganeti', 
                                 :cluster => 'cluster1.osuosl.org', 
                                 :created => DateTime.now, 
                                 :modified => DateTime.now)

  # do we have some registered plugins?
  puts "Plugins:"
  for plugin in Plugin.all do
    # what is this plugin's name?
    puts plugin.name
  end 

  # now lets collect data for all our projects (this will move to a scheduled task)
  
  for project in Project.all do
    # what resources does this project have?
    resources = project.resources.split(',')
    # get all the plugins that measure for each resource
    for resource in resources do
      puts resource
      if DB.table_exists?(resource + '_resources')
        # get the objects of this reource type belonging to this project
        model = Object.const_get(resource.capitalize + "Resource")
        resource_objects = model.where(:project_id => project.id)
        plugins = Plugin.where(:resource_type => resource)
        for resource_object in resource_objects do
          # so much nesting!
          for plugin in plugins do
            puts plugin.name
            plugin = Object.const_get(plugin.name)
            plugin.collect(resource_object)
          end
        end
      end
    end
  end

  # and then report the same way:

  for project in Project.all do
    # what resources does this project have?
    resources = project.resources.split(',')
    # get all the plugins that measure for each resource
    for resource in resources do
      puts resource
      if DB.table_exists?(resource + '_resources')
        # get the objects of this reource type belonging to this project
        model = Object.const_get(resource.capitalize + "Resource")
        resource_objects = model.where(:project_id => project.id)
        plugins = Plugin.where(:resource_type => resource)
        for resource_object in resource_objects do
          # so much nesting!
          for plugin in plugins do
            puts plugin.name
            plugin = Object.const_get(plugin.name)
            plugin.report(resource_object)
          end
        end
      end
    end
  end


end
