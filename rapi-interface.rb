require 'net/http'
require 'uri'
require 'openssl'
require 'json'
require 'redis'

redis = Redis.new

# Query database for each unique cluster fqdn
# for each cluster fqdn, append port number, endpoint, and query
fqdn = 'https://ganeti-psf.osuosl.bak'
endpoint = ':5080/2/instances'
query = '?bulk=1'
url = fqdn + endpoint + query
uri = URI(url)

Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https',
                :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
    # perform get request on full path.
    request = Net::HTTP::Get.new uri
    response = http.request request # Net::HTTPResponse object 
    
    # Store returned information in redis with datetime and cluster name
    redis.set(fqdn, response.body)
    redis.set(fqdn + '.datetime', Time.new.inspect)
    File.open("store/temp.json","w") do |f|
        f.write(response.body.to_json)
    end

end

