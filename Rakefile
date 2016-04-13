require 'sequel'

task :default => [:run]

task :run => [:migrate] do
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

task :test => [:migrate] do
  ruby 'app.rb'
end
