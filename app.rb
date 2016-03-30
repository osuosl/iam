# myapp.rb
require 'sinatra'

set :port => 8000
set :bind => '0.0.0.0'

get '/' do
  'Hello world!'
end
