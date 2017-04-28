# frozen_string_literal: true
# set path to app that will be used to configure unicorn,
# note the trailing slash in this example
app_dir = '/data/code'
pid_dir = '/tmp'

worker_processes 1
working_directory app_dir

timeout 30

# Set process id path
pid "#{pid_dir}/unicorn.pid"

# load the scheduler init script
require "#{app_dir}/scheduler"
# path to the scheduler pid file
scheduler_pid_file = "#{pid_dir}/scheduler.pid"

after_fork do |server, worker|
  # run scheduler initialization
  child_pid = server.config[:pid].sub('.pid', ".#{worker.nr}.pid")
  system("echo #{Process.pid} > #{child_pid}")

  # run scheduler initialization
  Scheduler.start_unless_running scheduler_pid_file
  Scheduler.start_unless_running scheduler_pid_file
end
