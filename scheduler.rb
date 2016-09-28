require 'rufus/scheduler'
require_relative 'collectors.rb'
require_relative 'environment.rb'
require_relative 'lib/util.rb'

cache = Cache.new(Iam.settings.cache_file)

class Scheduler
  # Starts the scheduler unless it is already running
  def self.start_unless_running(pid_file)
    with_lockfile(File.join(File.dirname(pid_file), 'scheduler.lock')) do
      if File.exists?(pid_file)
        pid = IO.read(pid_file).to_i
        if pid > 0 && process_running?(pid)
          puts "not starting scheduler because it already is running with pid #{pid}"
        else
          puts "Process #{$$} removes stale pid file"
          File.delete pid_file
        end
      end

      if !File.exists?(pid_file)
        # Write the current PID to the file
        (File.new(pid_file,'w') << $$).close
        puts "scheduler process is: #{$$}"

        # Execute the scheduler
        new.setup_jobs
      end
      true
    end or puts "could not start scheduler - lock not acquired"
  end

  # true if the process with the given PID exists, false otherwise
  def self.process_running?(pid)
    Process.kill(0, pid)
    true
  rescue Exception
    false
  end
    # executes the given block if the lock can be acquired, otherwise nothing is
  # done and false returned.
  def self.with_lockfile(lock_file)
    lock = File.new(lock_file, 'w')
    begin
      if lock.flock(File::LOCK_EX | File::LOCK_NB)
        yield
      else
        return false
      end
    ensure
      lock.flock(File::LOCK_UN)
      File.delete lock
    end
  end

  def initialize
    @rufus_scheduler = Rufus::Scheduler.new
    # install exception handler to report errors via Airbrake
    @rufus_scheduler.class_eval do
      define_method :handle_exception do |job, exception|
        puts "job #{job.job_id} caught exception '#{exception}'"
        Airbrake.notify exception
      end
    end
  end

#s = Rufus::Scheduler.new
  def setup_jobs
    @rufus_scheduler.every '30m', first_in: 0.4 do
      # Collect ganeti node information every 30 minutes
      collector = Collectors.new

      # Node (ganeti) collector
      clusters =  Iam.settings.ganeti_collector_clusters
      clusters.each do |v|
        collector.collect_ganeti(v)
      end

      # Database collector

      dbs = Iam.settings.db_collector_dbs

      dbs.each do |var|
        collector.collect_db(var[:type],
                             var[:host],
                             var[:user],
                             var[:password])
      end
    end

    # Change '15m' on next line to 4 to test
    @rufus_scheduler.every '30m', first_in: '15m' do
      `rake plugins`
      # For each entry in the plugins table
      Iam.settings.DB[:plugins].each do |p|
        # Require the plugin based on the name in the table
        require_relative "plugins/#{p[:name]}/plugin.rb"
        # For each key in cache
        cache.keys.each do |key|
          # Store the node information in the proper table with the plugin's store
          # method. The plugin object is retrieved from the name string using
          # Object.const_get. Do not try to store keys that store a datetime object.
          Object.const_get(p[:name]).new.store key unless key.end_with?('datetime')
        end
      end
    end
  end
end
