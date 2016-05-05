require 'sinatra/base'
require File.expand_path '../environment.rb', __FILE__

=begin
IaM: Invoicing and Metrics
  A resource usage metric collection and reporting system.
  Developed by the OSU Open Source Lab - 2016
=end
class Iam < Sinatra::Base
  # require the models, but make sure to do it after the test db is migrated
  require 'models'

  # load up all the plugins
  Dir[File.dirname(__FILE__) + '/plugins/*/plugin.rb'].each do
    |file| require file
  end

  e = ExamplePlugin.new

  e._foo()
  e.register('CPU', 'cpus', 'node')

end
