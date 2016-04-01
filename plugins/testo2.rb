require 'sinatra/base'
require 'models'
require 'sequel'
require 'sqlite3'

class TestoTwo

  #DB = Sequel.sqlite('dev.db')


  def self.register_plugin()

    DB.create_table? :testotwo_measurements do
      primary_key :id
      foreign_key :resource_id, :node_resources  # this is plugin specific!
      String      :value
      DateTime    :created
    end

    # add this plugin's info to the plugins table
    Plugin.create(:name => 'TestoTwo', :resource_type => 'node', :storage_table => 'testotwo_measurements', :units => 'flops')
  end

  def self.report(resource)
    dataset = DB[:testotwo_measurements]
    puts "current Testo Two data:"
    for row in dataset.all do
      puts row
    end
  end
  
  def self.collect(resource)
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    value = (0...16).map { o[rand(o.length)] }.join
    dataset = DB[:testotwo_measurements]
    dataset.insert(:resource_id => resource.id, :value => value, :created => DateTime.now)
  end
 
  if !DB.table_exists?('testotwo_measurements')
    self.register_plugin()
  end
  
end


