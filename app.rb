# myapp.rb
require 'sinatra/base'
require 'sequel'

# Include database models.
# Run `rake migrations` to create the database.


class Iam < Sinatra::Base
  # DB = Sequel.connect(ENV.fetch('DATABASE_URL'))
  DB = Sequel.connect('sqlite://test.db')
  require_relative 'models'
  # load up all the plugins
  Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each {|file| require file }

  ##
  # Report
  ##

  get '/report' do
    data = DiskSizePlugin::report()
  end

  get '/report/:fqdn' do |fqdn|

    data = DiskSizePlugin::report(fqdn)
  end

  run!
end

