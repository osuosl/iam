#!/usr/bin/env rake

# default rake cmd
task default: %w(lint app)

# rake app task
task :app do
  puts 'Running app...'
  require './app'
end

# rake lint
task :lint do
  puts 'Running RuboCop...'
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

task :docker do
  puts 'Running docker...'
end
