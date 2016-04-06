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
    # TODO: Query database for each unique cluster name
    @cluster = ['ganeti']
    @template = ERB.new File.new('datastruct.erb').read, nil, '%'
  end

  # Public: Queries Ganeti by cluster to receive node information via the Ganeti
  #         RAPI. Stores the information in redis.
  def collect_ganeti
    @cluster.each do |name|
      # for each cluster, append port number, endpoint, and query.
      uri = URI("https://#{name}.osuosl.bak:5080/2/instances?bulk=1")
      Net::HTTP.start(uri.host, uri.port,
                      use_ssl:     uri.scheme == 'https',
                      verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        # perform get request on full path.
        response = http.request Net::HTTP::Get.new uri
        # Store returned information in redis with datetime and node name
        JSON.parse(response.body).each do |node|
          node_name          = node['name']                     || 'unknown'
          disk_sizes_meas    = node['disk.sizes']               || 'unknown'
          disk_usage_meas    = node['disk_usage']               || 'unknown'
          disk_template_meas = node['disk_template']            || 'unknown'
          num_cpus_meas      = node['oper_vcpus']               ||
                               node['beparams']['vcpus']        ||
                               node['custom_beparams']['vcpus'] || 'unknown'
          total_ram_meas     = node['beparams']['memory']       || 'unknown'

          @redis.set(node_name, @template.result(binding))
          @redis.set(node_name + ':datetime', Time.new.inspect)
        end
        # To retrieve the the node information, use redis.get and JSON.parse.
        # This will give you a ruby hash of the node information.
        # info = JSON.parse(@redis.get(<node_name>))
        # time = @redis.get(<node_name> + ':datetime')
      end
    end
  end
end

# To test the collect_ganeti method, uncomment the following line.
# Collectors.new.collect_ganeti
