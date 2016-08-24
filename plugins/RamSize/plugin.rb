require 'sequel'
require 'logging'
require_relative '../../lib/BasePlugin/plugin.rb'
require_relative '../../environment.rb'
require_relative '../../models.rb'
require_relative '../../logging/logs'

# Ram Size data plugin
class RamSize < BasePlugin
  def initialize
    @@name = 'RamSize'
    @@resource_name = 'node'
    @@units = 'mb'
    @@table = :ram_size_measurements
    @@db_column = :ram_size_ver
    @@migrations_dir= File.dirname(__FILE__) + '/migrations'
    @@database = Iam.settings.DB
    @cache = Cache.new(ENV['CACHE_FILE'])
    register
  end

  def store(fqdn)

    # Pull node information from cache as a ruby hash
    node_info = @cache.get(fqdn)

    # Error check for valid data
    if node_info['total_ram'].nil? || node_info['total_ram'] == 'unknown'
      MyLog.log.error StandardError.new(
        "No total_ram information for #{fqdn}"
      )
    elsif not node_info['total_ram'].number?
      MyLog.log.error StandardError.new(
        "RamSize: total_ram information for #{fqdn} malformed (should be number)"
      )
      raise "RamSize: total_ram information for #{fqdn} malformed (should be number)"
    end

    # Insert data into disk_size_measurements table
    @@database[@@table].insert(
      node:          fqdn,
      value:         node_info['total_ram'].to_i,
      active:        node_info['active'],
      created:       DateTime.now,
      node_resource: @@database[:node_resources].where(name: fqdn).get(:id))
  rescue => e                        # Don't crash on errors
    MyLog.log.error StandardError.new("RamSize:  #{e}: #{node_info}")
  end
end
