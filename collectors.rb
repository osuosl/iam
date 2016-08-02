require 'net/http'
require 'uri'
require 'openssl'
require 'json'
require 'erb'
require_relative 'lib/util'

# Collectors class to hold collection methods for specific node management
# systems, such as ganeti, chef, etc.
class Collectors
  def initialize
    @cache = Cache.new(ENV['CACHE_FILE'])
    # TODO: Query database for each unique cluster name
    @cluster = ['ganeti']
    @template = ERB.new File.new('datastruct.erb').read, nil, '%'
  end

  # Public: Queries Ganeti by cluster to receive node information via the Ganeti
  #         RAPI. Stores the information in the file cache.
  def collect_ganeti
    @cluster.each do |name|
      # for each cluster, append port number, endpoint, and query.
      uri = URI("https://#{name}.osuosl.bak:5080/2/instances?bulk=1")
      begin
        Net::HTTP.start(uri.host, uri.port,
                        use_ssl:     uri.scheme == 'https',
                        verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
          # perform get request on full path. If this doesn't work, program
          # control will jump to the rescue block below.
          response = http.request Net::HTTP::Get.new uri
          # Store returned information in with datetime and node name
          JSON.parse(response.body).each do |node|
            node_name          = node['name']                     || 'unknown'
            disk_sizes_meas    = node['disk.sizes']               || 'unknown'
            disk_usage_meas    = node['disk_usage']               || 'unknown'
            disk_template_meas = node['disk_template']            || 'unknown'
            num_cpus_meas      = node['oper_vcpus']               ||
                                 node['beparams']['vcpus']        ||
                                 node['custom_beparams']['vcpus'] || 'unknown'
            total_ram          = node['beparams']['memory']       || 'unknown'
            active_meas        = node['oper_state']

            @cache.set(node_name, JSON.parse(@template.result(binding)))
            @cache.set(node_name + ':datetime', Time.new.inspect)
          end
          # To retrieve the the node information, use cache.get and JSON.parse.
          # This will give you a ruby hash of the node information.
          # info = @cache.get(<node_name>)
          # time = @cache.get(<node_name> + ':datetime')
        end
      rescue SocketError
        STDERR.puts "Uh oh, got a SocketError connecting to #{name}"
      end
    end
    @cache.write
  end
  
  def collect_db
    # collect mysql
    self.collect_mysql
    # collect postgres
    self.collect_postgres
  end

  def collect_mysql
    # collect mysql metadata
  end

  def collect_postgres
    # collect postgres metadata
  end
end

c = Collectors.new
c.collect_ganeti
# To test the collect_ganeti method, uncomment the following line.
# Collectors.new.collect_ganeti
