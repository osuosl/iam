require 'sequel'
require 'logging'
require_relative '../../lib/BasePlugin/plugin.rb'
require_relative '../../environment.rb'
require_relative '../../models.rb'

# DiskTemplate plugin
class DiskTemplate < BasePlugin
  def initialize
    @@name = 'DiskTemplate'
    @@resource_name = 'node'
    @@units = 'type'
    @@table = :disk_template_measurements
    @@db_column = :disk_template_ver
    @@migrations_dir = File.dirname(__FILE__) + '/migrations'
    @@database = Iam.settings.DB
    @cache = Cache.new(ENV['CACHE_FILE'])
    register
  end

  def store(fqdn)
    # initialize a log
    log = Logging.logger['DiskTemplateLog']
    log.level = :debug
    log.add_appenders(
      Logging.appenders.file(
      ENV['LOG_FILE_PATH'] ? ENV['LOG_FILE_PATH'] : 'logging/log_file.log')
    )

    # Pull node information from cache as a ruby hash
    node_info = @cache.get(fqdn)

    # Error check for valid data
    if node_info['disk_template'].nil?
      log.warn "DiskTemplate: No disk_template information for #{fqdn}"
    end

    # Insert data into disk_size_measurements table
    @@database[@@table].insert(
      node:          fqdn,
      value:         node_info['disk_template'],
      active:        node_info['active'],
      created:       DateTime.now,
      node_resource: @@database[:node_resources].where(name: fqdn).get(:id))
  rescue => e                        # Don't crash on errors
    log.error StandardError.new("DiskTemplate:  #{e}: #{node_info}")
  end

end
