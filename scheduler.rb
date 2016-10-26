require 'rufus/scheduler'
require_relative 'collectors.rb'
require_relative 'environment.rb'
require_relative 'lib/util.rb'

<<<<<<< HEAD
# schedule class will only start a scheduler if one is not already running
# TODO: make this simpler for Rubocop's sake
class Scheduler
  # rubocop:disable AbcSize, MethodLength
  def self.start_unless_running(pid_file)
    with_lockfile(File.join(File.dirname(pid_file), 'scheduler.lock')) do
      if File.exist?(pid_file)
        pid = IO.read(pid_file).to_i
        if pid > 0 && process_running?(pid)
          puts "not starting: scheduler is already running with pid #{pid}"
        else
          puts "Process #{$PID} removes stale pid file"
          File.delete pid_file
        end
      else
        # Write the current PID to the file
        (File.new(pid_file, 'w') << $PID).close
        puts "scheduler process is: #{$PID}"
=======
cache = Cache.new(ENV['CACHE_FILE'])
db_cache = Cache.new(ENV['DB_CACHE_FILE'])
>>>>>>> first draft of segregating the db_cache

        # Execute the scheduler
        new.setup_jobs
      end
      return true
    end
    puts 'could not start scheduler - lock not acquired'
  end
  # rubocop:enable AbcSize, MethodLength

  # true if the process with the given PID exists, false otherwise
  def self.process_running?(pid)
    Process.kill(0, pid)
    true
  rescue StandardError
    false
  end

  # executes the given block if the lock can be acquired, otherwise nothing is
  # done and false returned.
  # TODO: make this simpler for Rubocop's sake
  def self.with_lockfile(lock_file)
    lock = File.new(lock_file, 'w')
    begin
      return false unless lock.flock(File::LOCK_EX | File::LOCK_NB)
      yield
    ensure
      lock.flock(File::LOCK_UN)
      File.delete lock
    end
  end

  def initialize
    @rufus_scheduler = Rufus::Scheduler.new
    @cache = Cache.new(Iam.settings.cache_file)
  end

<<<<<<< HEAD
  def setup_jobs
    @rufus_scheduler.every '30m', first_in: 0.4 do
      db_collector_job
    end

    @rufus_scheduler.every '30m', first_in: 0.4 do
      ganeti_collector_job
    end

    # offset schedule for plugins - run the store methods 15 minutes after
    # the collector methods run
    @rufus_scheduler.every '30m', first_in: '15m' do
      `rake plugins`
      plugins_job
=======
# Change '15m' on next line to 4 to test
s.every '30m', first_in: '15m' do
  `rake plugins`
  # For each entry in the plugins table
  Iam.settings.DB[:plugins].each do |p|
    # Require the plugin based on the name in the table
    require_relative "plugins/#{p[:name]}/plugin.rb"

    # if DBSIZE plugin, use the db_cache, otherwise use the regular cache
    if p[:name] == 'DBSize'
      db_cache.keys.each do |key|
        unless key.end_with?('datetime')
          Object.const_get(p[:name]).new.store key
        end
      end
    else
      # For each key in cache
      cache.keys.each do |key|
        # Store the node information in the proper table with the plugin's store
        # method. The plugin object is retrieved from the name string using
        # Object.const_get. Do not try to store keys that store a datetime
        # object.
        unless key.end_with?('datetime')
          Object.const_get(p[:name]).new.store key
        end
      end
>>>>>>> first draft of segregating the db_cache
    end
  end

  # Run the store method of every registered plugin on all the collected data
  # in the cache
  def plugins_job
    # For each entry in the plugins table
    Iam.settings.DB[:plugins].each do |p|
      # Require the plugin based on the name in the table
      require_relative "plugins/#{p[:name]}/plugin.rb"
      # For each key in cache
      @cache.keys.each do |key|
        # Store the node information in the proper table with the plugin's
        # store method. The plugin object is retrieved from the name string
        # using Object.const_get. Do not try to store keys that store a datetime
        # object.
        unless key.end_with?('datetime')
          Object.const_get(p[:name]).new.store key
        end
      end
    end
  end

  def db_collector_job
    # Database collector
    collector = Collectors.new
    dbs = Iam.settings.db_collector_dbs
    dbs.each do |var|
      collector.collect_db(var['type'],
                           var['host'],
                           var['user'],
                           var['password'])
    end
  end

  def ganeti_collector_job
    # Collect ganeti node information every 30 minutes
    collector = Collectors.new

    # Node (ganeti) collector
    clusters =  Iam.settings.ganeti_collector_clusters
    clusters.each do |v|
      collector.collect_ganeti(v)
    end
  end
end
