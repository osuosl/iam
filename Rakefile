require 'rake'
require 'rspec/core/rake_task'


task :default do

  ENV['RACK_ENV'] = 'test'
  Rake::Task['test'].invoke
end
 

namespace :db do
  desc "Run database migrations"
  task :migrate, :env do |cmd, args|
    env = args[:env] || "development"
    Rake::Task['environment'].invoke(env)

    require 'sequel/extensions/migration'
    Sequel::Migrator.apply(Foo::Database, "db/migrate")
  end

  desc "Nuke the database (drop all tables)"
  task :nuke, :env do |cmd, args|
    env = args[:env] || "development"
    Rake::Task['environment'].invoke(env)
    Foo::Database.tables.each do |table|
      Foo::Database.run("DROP TABLE #{table}")
    end
  end

  desc "Reset the database"
  task :reset, [:env] => [:nuke, :migrate]
end


RSpec::Core::RakeTask.new(:spec) do |t|
	ENV["RACK_ENV"] = "test"
	t.pattern = Dir.glob('spec/**/*_spec.rb')
	t.rspec_opts = '--format documentation'
end

