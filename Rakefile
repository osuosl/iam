require 'rake'

 
task :default do

  ENV['RACK_ENV'] = 'test'
  Rake::Task['test'].invoke
end
 
Rake::TestTask.new(:default) do |t|

  t.libs << "test"
  t.pattern = 'spec/*_spec.rb'
  t.verbose = true
end
