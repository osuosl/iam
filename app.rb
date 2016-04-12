# myapp.rb
require 'sinatra'

set :port => 8000
set :bind => '0.0.0.0'

get '/' do
  'Hello world! <a href=/foo>other page</a>'
end

get '/foo' do
  'This is another page!'
end
