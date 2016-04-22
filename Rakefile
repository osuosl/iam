require 'sequel'

task default: [:run]

task run: [:migrate] do
  ruby 'app.rb'
end

task :migrate do
  require 'sequel'
  Sequel.extension :migration
  db = Sequel.connect(ENV.fetch('DATABASE_URL'))
  puts 'Migrating to latest'
  Sequel::Migrator.run(db, 'migrations')
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
