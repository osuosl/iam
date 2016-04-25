require 'sinatra/base'
require 'models'
require 'sequel'
require 'sqlite3'
require 'redis'
require_relative '../collectors'

class DiskSizePlugin


  def self.register_plugin()
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
    #   construct hash to return, then return

  end

  def self.collect(fqdn)
    dataset = DB[:disk_size_measurements]
    redis = Redis.new

    begin
      node_info = JSON.parse(redis.get(fqdn))
      disk_sizes = node_info['disk_sizes']
      active = node_info['oper_state'] ? 1 : 0
      dataset.insert(:resource_id => fqdn,
                     :value       => eval(disk_sizes).inject(0, :+),
                     :active      => active,
                     :created     => DateTime.now)
    rescue
      STDERR.puts "There was an error"
    end
  end

  if !DB.table_exists?('disk_size_measurements')
    self.register_plugin()
  end

end

