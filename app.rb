# myapp.rb
require 'sinatra/base'

# Include database models.
# Run `rake migrations` to create the database.
require_relative 'models'

class Iam < Sinatra::Base
  # test API for the time being
  set :port, 8000
  set :bind, '0.0.0.0'

  get '/' do
    'Hello world! <a href=/foo>other page</a>'
  end
  get '/foo' do
    'This is another page!'
  end

  get '/demo' do
    require './collectors.rb'
    @data = Collectors.new.report
    # @data = JSON.parse(@data)
    puts @data
    erb :demo
  end

  run! if app_file == $PROGRAM_NAME
end
