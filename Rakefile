require 'sequel'

task default: [:run]

task run: [:migrate] do
  ruby 'app.rb'
end

task :migrate, [:version] do |t, args|
  require 'sequel'
  Sequel.extension :migration
  db = Sequel.connect(ENV.fetch('DATABASE_URL'))
  if args[:version]
    puts 'Migrating to version #{args[:version]}'
    Sequel::Migrator.run(db, 'migrations', target: args[:version].to_i)
  else
    puts 'Migrating to latest'
    Sequel::Migrator.run(db, 'migrations')
  end
end

task test: [:migrate] do
  ruby 'app.rb'
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

RSpec::Core::RakeTask.new(:spec) do |t|
    ENV["RACK_ENV"] = "test"
    t.pattern = Dir.glob('spec/**/*_spec.rb')
    t.rspec_opts = '--format documentation'
end