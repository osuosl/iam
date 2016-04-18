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
    redis = Redis.new
    nodes = redis.keys(fqdn)
    data = {}
    temp = {}

    # for each node in the redis db, get key and value, then sum
    nodes.each do |key|
      unless key.end_with?(':datetime')
        node_info = JSON.parse(redis.get(key))
        disk_sizes = node_info['disk_sizes']  # This is a list of integers
        sum = 0
        eval(disk_sizes).each do |disk_size|
          sum += Integer(disk_size)
        end
        printf("%-40s %-7d bytes of %s\n", key, sum, node_info['disk_template'])
        temp['disk_template'] = node_info['disk_template'] || 'unknown'
        temp['disk_size'] = sum
        data[key] = temp
      end
    end

    # 'return  data', might be redundant but better safe than sorry
    return data
  end

  def self.collect(resource)
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    value = (0...16).map { o[rand(o.length)] }.join
    dataset = DB[:testo_measurements]
    dataset.insert(:resource_id => resource.id,
                   :value => value,
                   :created => DateTime.now)
  end

  # Future, do this
  # if !DB.table_exists?('testo_measurements')
  #   self.register_plugin()
  # end

end

disk_sizes = DiskSizePlugin.report()

