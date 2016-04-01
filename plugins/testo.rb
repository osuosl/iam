require 'sinatra/base'
require 'models'
require 'sequel'
require 'sqlite3'

# TESTO class documentation goes here
class Testo
  def self.register_plugin
    DB.create_table? :testo_measurements do
      primary_key :id
      foreign_key :resource_id, :node_resources # this is plugin specific!
      String      :value
      DateTime    :created
    end

    # add this plugin's info to the plugins table
    Plugin.create(name: 'Testo', resource_type: 'node',
                  storage_table: 'testo_measurements', units: 'bogomips')
  end

  def self.report
    dataset = DB[:testo_measurements]
    puts 'current Testo data:'
    dataset.all.each do |row|
      puts row
    end
  end

  def self.collect(resource)
    o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
    value = (0...16).map { o[rand(o.length)] }.join
    dataset = DB[:testo_measurements]
    dataset.insert(resource_id: resource.id, value: value,
                   created: DateTime.now)
  end

  register_plugin unless DB.table_exists?('testo_measurements')
end
