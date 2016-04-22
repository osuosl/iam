require 'sinatra/base'
require File.expand_path '../environment.rb', __FILE__

# IAM - a resource usage metric collection and reporting system
class Iam < Sinatra::Base
  # require the models, but make sure to do it after the test db is migrated
  require 'models'

  # load up all the plugins
  Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each { |file| require file }

  ##
  # static Pages
  ##

  get '/' do
    'Hello'
  end

  ##
  # Clients
  ##

  get '/clients' do
    @clients = Client.each { |x| p x.name }
    erb :'clients/index'
  end

  get '/clients/new' do
    erb :'clients/new'
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
