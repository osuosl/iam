# require 'sequel'
require 'rake'
require 'rspec/core/rake_task'
require_relative 'environment'

task default: [:run]

task run: [:migrate] do
  ruby 'app.rb'
  ruby 'scheduler.rb'
end

task :require_verify_db do
  input = ''
  STDOUT.puts "\n"\
    "******************************************\n"\
    "WARNING! ONLY FOR USE IN DEV ENVIRONMENTS!\n"\
    "******************************************\n\n"\
    "This will permanently destroy all current data in this instance of the "\
    "application, are you sure?\n\nType yes in all uppercase to verify:"
  input = STDIN.gets.chomp
  abort("Whew, that was close!") unless input == "YES"
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
  end
end

# rake spec
RSpec::Core::RakeTask.new(:spec) do |t|
  ENV['RACK_ENV'] = 'test'
  t.pattern = Dir.glob('{lib,spec,plugins,logging}/**/*spec.rb')
  t.rspec_opts = '--format documentation'
end

# rake plugins
task :plugins do
  puts 'Registering plugins'
  # Get name of each plugin from folder name. Require each plugin and register.
  # At this point, we are assuming the plugin is *not* registered and is
  # therefore not in the plugins table.
  Dir['plugins/*/plugin.rb'].each do |name|
    require name
    # The actual name is the middle part of the path (plugin/<name>/plugin.rb).
    Object.const_get(name.split('/')[1]).new
  end
end

# rake export_data
task :export_data => [:plugins] do
  desc "export data"
  days = ENV['EXPORT_DATA_DAYS'] ||= '60'
  clients = ENV['EXPORT_DATA_CLIENTS'] ||= 'all'
  anon = ENV['EXPORT_DATA_ANON'] == 'false' ? false : true

  STDOUT.puts "\n"\
    "********\n"\
    "WARNING!\n"\
    "********\n\n"\
    "You are exporting IDENTIFYING DATA\n"\
    "DO NOT ADD THIS DATA TO A PUBLIC REPOSITORY!\n" unless anon

  require_relative 'lib/datasampler.rb'
  puts 'Fetching live data'
  exporter = DataExporter.new
  exporter.export_data(days: days.to_i,
                       client_list: clients.split(','),
                       anon: anon)
  puts 'Data samples written to ./test_data/'
end

# rake import_testdata
task :import_data => [:plugins, :require_verify_db] do
  require_relative 'lib/datasampler.rb'
  puts 'Importing test data from ./test_data'
  importer = DataImporter.new
  importer.import_data
  puts 'Data samples imported from ./test_data/'
end
