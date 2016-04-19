require 'net/http'
require 'uri'
require 'openssl'
require 'json'
require 'redis'

redis = Redis.new(:host => ENV["REDIS_HOST"])

# TODO: Query database for each unique cluster fqdn
# for each cluster fqdn, append port number, endpoint, and query
fqdn = ['ganeti-psf.osuosl.bak', 'ganeti-civicrm.osuosl.bak']
fqdn.each do |name|
    endpoint = ':5080/2/instances'
    query = '?bulk=1'
    url = 'https://' + name + endpoint + query
    uri = URI(url)

    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https',
                    :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
        # perform get request on full path.
        request = Net::HTTP::Get.new uri
        response = http.request request # Net::HTTPResponse object

        # Store returned information in redis with datetime and cluster name
        redis.set(name, response.body)
        redis.set(name + ':datetime', Time.new.inspect)
        puts redis.get(name)
        puts redis.get(name + ':datetime')
    end
end

# To retrieve the the cluster information, use redis.get and JSON.parse. This
# will give you a ruby hash of the cluster information.
#
# cluster_info = JSON.parse(redis.get("ganeti-psf.osuosl.bak"))
