require 'sequel'
require_relative '../../environment.rb'
require_relative '../../models.rb'

class BasePlugin
  SECONDS_IN_DAY = 60 * 60 * 24
  @@redis = Redis.new(host: ENV['REDIS_HOST'])
  @@database = Iam.settings.DB

  @@name = nil
  @@resource_name = nil
  @@units = nil
  @@table = nil
  @@db_column = nil
  @@migrations_dir = nil

  def register
    Plugin.find_or_create(name: @@name, # create entry in Plugins table
                          resource_name: @@resource_name,
                          storage_table: @table.to_s,
                          units: @@units)
    # execute migration
    Sequel::Migrator.run(@@database,
                         @@migrations_dir,
                         column: @@db_column)
  end

  # General report function
  # Returns Ruby Hash of report data
  def report(fqdn = '*', start_time = Time.now - (30 * SECONDS_IN_DAY),
             end_time = Time.now)
    raise TypeError.new("start_time and end_time should be Time objects")\
      unless end_time.is_a? Time and start_time.is_a? Time
    raise ArgumentError.new("start_time > end_time")\
      unless start_time < end_time

    # if fqdn is default, return all
    if fqdn == '*'
      dataset = @@database[@@table].where(created: start_time..end_time)
    # else return data filtered with fqdn name
    else
      dataset = @@database[@@table].where(node: fqdn)
                                   .where(created: start_time..end_time)
    end
    # Reports in a ruby hash
    dataset.all
  end
end
