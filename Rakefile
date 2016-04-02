#!/usr/bin/env rake

task default: %w(lint app)

task :app do
  puts 'Running app'
  require './app'
end

task :lint do
  puts 'Running RuboCop ...'
  require 'rubocop/rake_task'

  desc 'Run RuboCop on the current directory'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.patterns = ['**/*.rb']
    # only show the files with failures
    task.formatters = ['files']
    # don't abort rake on failure
    task.fail_on_error = false
  end
end
