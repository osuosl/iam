require 'sinatra/base'
#require 'models'
#require 'sequel'
#require 'sqlite3'
require 'redis'
require_relative '../collectors'

class DiskSizePlugin


  def self.register_plugin()

    DB.create_table? :disk_size_measurements do
      primary_key :id
      foreign_key :resource_id, :node_resources  # this is plugin specific!
      String      :value
      DateTime    :created
    end

    # add this plugin's info to the plugins table
    Plugin.create(:name          => 'disk_size',
                  :resource_type => 'node',
                  :storage_table => 'disk_size_measurements',
                  :units         => 'bytes')
  end

  def self.report(fqdn='*')
    # Future, do this
    # dataset = DB[:disk_size_measurements]
    # for row in dataset.all do
    #   the logic outlined below

    # Future, redis access will go to self.collect
    # and this method will pull from DB as described above
    dataset = DB[:disk_size_measurement]
    if fqdn == '*'
      return dataset.all
    end

    data = {}

    dataset.each do |row|
      if row.name == fqdn
        # Do logic here
        data[row.name] = row
      end
    end

    return data
  end

  def self.collect(resource)

  end

  # Future, do this
  # if !DB.table_exists?('testo_measurements')
  #   self.register_plugin()
  # end

end

