#!/usr/bin/env rake

# vars
NAME = 'centos-ruby'.freeze

# default rake cmd
task default: %w(rubocop run)

# rake app task
task :run do
  desc 'Runs app'
  puts 'Running app...'
  exec 'docker-compose run --service-ports --rm dev_$USER bash'
end

# rake lint
task :rubocop do
  require 'rubocop/rake_task'

  desc 'Run RuboCop on the current directory'
  # run rubocop recursively through all the files
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.patterns = ['**/*.rb']
    # only show the files with failures
    task.formatters = ['files']
    # don't abort rake on failure
    task.fail_on_error = false
  end
end

task :build do
  desc 'Build Docker Containers'
  puts 'Building Docker containers...'
  exec 'docker-compose build'
end

task :clean do
  desc 'Destroy Docker containers'
  puts 'Destroying Docker containers...'
  exec 'docker-compose down'
  puts 'Building Docker contianers'
  exec 'docker-compose build'
end

###################################
# HELPER FUNCTIONS
###################################

# helper function to check if docker image exists
# returns true if image exists
def image_exists(name)
  `docker images -q #{name}` != ''
end

# helper function to pass commands to the docker container
# it should NOT detach the container after execution because of the -i in -it
# params
def run_command(command)
  # TODO: test this
  exec 'docker exec -it #{NAME} ' + command if image_exists(NAME)
end
