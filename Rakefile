# require 'sequel'
require 'rake'
require 'rspec/core/rake_task'
require File.expand_path '../environment.rb', __FILE__

task default: [:run]

task run: [:migrate] do
  ruby 'app.rb'
end

task :migrate, [:version] do |t, args|
  if args[:version]
    puts "Migrating to version #{args[:version]}"
    Sequel::Migrator.run(Iam.DB, 'migrations', target: args[:version].to_i)
  else
    puts 'Migrating to latest'
    Sequel::Migrator.run(Iam.DB, 'migrations')
  end
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

# rake spec
RSpec::Core::RakeTask.new(:spec) do |t|
  ENV['RACK_ENV'] = 'test'
  t.pattern = Dir.glob('{spec,plugins}/**/*spec.rb')
  t.rspec_opts = '--format documentation'
end

# rake plugins
task :plugins do
  puts 'Registering plugins'
  # Get name of each plugin from folder name. Require each plugin and register.
  # At this point, we are assuming the plugin is *not* registered and is
  # therefore not in the plugins table.
  Dir['plugins/*'].each do |name|
    require "#{name}/plugin.rb"
    # The actual name is the last part of the filename (plugin/<name>).
    Object.const_get(File.split(name)[-1]).new
  end
end
