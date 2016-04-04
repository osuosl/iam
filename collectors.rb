require 'net/http'
require 'uri'
require 'openssl'
require 'json'
require 'redis'
require 'erb'

# Collectors class to hold collection methods for specific node management
# systems, such as ganeti, chef, etc.
class Collectors
  def initialize
    @redis = Redis.new
    # TODO: Query database for each unique cluster fqdn
    # for each cluster fqdn, append port number, endpoint, and query.
    @fqdn = ['ganeti']
    @template = ERB.new File.new("datastruct.erb").read, nil, "%"
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
        # measurements will store information for each node
        measurements = {}
        # Store returned information in redis with datetime and node name
        node_info = JSON.parse(response.body)
        node_info.each do |hash|
          node_name          = hash['name']                     || "unknown"
          disk_sizes_meas    = hash['disk.sizes']               || "unknown"
          disk_usage_meas    = hash['disk_usage']               || "unknown"
          disk_template_meas = hash['disk_template']            || "unknown"
          num_cpus_meas      = hash['oper_vcpus']               ||
                               hash['beparams']['vcpus']        ||
                               hash['custom_beparams']['vcpus'] || "unknown"
          total_ram_meas     = hash['beparams']['memory']       || "unknown"

          measurements[node_name] = eval(@template.result(binding))
          
          @redis.set(node_name, measurements[node_name].to_json)
          @redis.set(node_name + ':datetime', Time.new.inspect)
        end
        # To retrieve the the cluster information, use redis.get and JSON.parse.
        # This will give you a ruby hash of the cluster information.
        # info = JSON.parse(@redis.get(<node_name>))
        # time = @redis.get(<node_name> + ':datetime')
      end
    end
  end
end

# To test the collect_ganeti method, uncomment the following line.
# Collectors.new.collect_ganeti
