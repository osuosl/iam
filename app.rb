require 'sinatra/base'
require File.expand_path '../environment.rb', __FILE__

# IAM - a resource usage metric collection and reporting system
class Iam < Sinatra::Base
  set :show_exceptions, :after_handler
  # require the models, but make sure to do it after the test db is migrated
  require 'models'

  # load up all the plugins
  plugin_dirs = File.dirname(__FILE__) + '/plugins/**/'

  Rake::FileList[plugin_dirs + 'plugin.rb'].each do |file|
    require file
  end

  ##
  # Errors
  ##
  error 404 do
    'Not Found'
  end

  ##
  # static Pages
  ##

  get '/' do
    'Hello'
  end

  ##
  # Clients
  ##

  get '/clients/new' do
    # get new client form
    erb :'clients/edit'
  end

  get '/clients/:id' do
    # view a client
    @client = Client[id: params[:id]]
    halt 404, 'Client not found' if @client.nil?
    erb :'clients/show'
  end

  get '/clients/:id/edit' do
    # get client edit form
    @client = Client[id: params[:id]]
    halt 404, 'Client not found' if @client.nil?
    erb :'clients/edit'
  end

  get '/clients' do
    # get a list of all clients
    @clients = Client.each { |x| p x.name }
    erb :'clients/index'
  end

  # This could also be PUT
  post '/clients' do
    # recieve new client
    client = Client.create(name: params[:name],
                           description: params[:description] || '',
                           contact_email: params[:contact_name] || '',
                           contact_name: params[:contact_email] || '')
    redirect "/clients/#{client.id}"
  end

  patch '/clients' do
    # recieve an updated client
    client = Client[id: params[:id]]

    client.update(name: params[:name] || client.name,
                  description: params[:description] || client.description,
                  contact_email: params[:contact_name] || client.contact_name,
                  contact_name: params[:contact_email] || client.contact_email)
    redirect "/clients/#{params[:id]}"
  end

  delete '/clients/:id' do
    # delete a client
    @client = Client[id: params[:id]]
    @client.delete unless @client.nil?
    redirect '/clients' unless @client.nil?
    404
  end

  ## TODO - move this somewhere
  redis = Redis.new(host: ENV['REDIS_HOST'])

  # TODO: Query database for each unique cluster fqdn
  # for each cluster fqdn, append port number, endpoint, and query
  fqdn = ['ganeti-psf.osuosl.bak', 'ganeti-civicrm.osuosl.bak']
  fqdn.each do |name|
    endpoint = ':5080/2/instances'
    query = '?bulk=1'
    url = 'https://' + name + endpoint + query
    uri = URI(url)

    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: uri.scheme == 'https',
                    verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      # perform get request on full path.
      request = Net::HTTP::Get.new uri
      response = http.request request # Net::HTTPResponse object

      # Store returned information in redis with datetime and cluster name
      redis.set(name, response.body)
      redis.set(name + ':datetime', Time.new.inspect)
      # puts redis.get(name)
      # puts redis.get(name + ':datetime')
    end
  end

  # To retrieve the the cluster information, use redis.get and JSON.parse. This
  # will give you a ruby hash of the cluster information.
  #
  # cluster_info = JSON.parse(redis.get("ganeti-psf.osuosl.bak"))
end
