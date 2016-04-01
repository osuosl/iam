require 'net/http'
require 'uri'
require 'openssl'
require 'json'
require 'redis'

# Collectors class to hold collection methods for specific node management
# systems, such as ganeti, chef, etc.
class Collectors
  def initialize
    @redis = Redis.new
    # TODO: Query database for each unique cluster fqdn
    # for each cluster fqdn, append port number, endpoint, and query.
    @fqdn = ['ganeti']
  end

  # Public: Queries Ganeti clusters by fqdn to receive node information via
  #         the Ganeti RAPI. Stores the information in redis.
  def collect_ganeti
    @fqdn.each do |name|
      uri = URI("https://#{name}.osuosl.bak:5080/2/instances?bulk=1")
      Net::HTTP.start(uri.host, uri.port,
                      use_ssl:     uri.scheme == 'https',
                      verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        # perform get request on full path.
        response = http.request Net::HTTP::Get.new uri
        # Store returned information in redis with datetime and cluster name
        @redis.set(name, response.body)
        @redis.set(name + ':datetime', Time.new.inspect)
        # To retrieve the the cluster information, use redis.get and JSON.parse.
        # This will give you a ruby hash of the cluster information.
        #
        # cluster_info = JSON.parse(redis.get("ganeti"))
        # print cluster_info
      end
    end
  end
end

# To test the collect_ganeti method, uncomment the following line
# Collectors.new.collect_ganeti
