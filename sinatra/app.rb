# sinatra setup prototype
# OSUOSL March 2016

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'date'

# preprocess the json from server
# TODO: change data source to redis
file = File.read('sample.json')
data = JSON.parse(file)

# default helloworld
get '/' do
  "Hello World!"
end

# returns bulk data
get '/data' do
  content_type:json
  data.to_json
end

# returns data for the vm #index from the server
get '/data/:index' do |index|
  index = Integer(index)

  content_type:json
  data[index].to_json
end

# returns the data we care about for the vm #index
get '/data/:index/stats' do |index|
  index = Integer(index)
  vm = data[index]
  content_type:json
  {
    :name => vm["name"],
    :create_time => vm["ctime"],
    :status => vm["status"],
    :vcpus => vm["oper_vcpus"],
    :ram => vm["oper_ram"],
    :disk => vm["disk_usage"],
    :os => vm["os"]
    # TODO: change response to match the scope
  }.to_json
end
