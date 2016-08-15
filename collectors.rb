require 'net/http'
require 'uri'
require 'openssl'
require 'json'
require 'erb'
require 'logging'
require_relative 'lib/util'

# Collectors class to hold collection methods for specific node management
# systems, such as ganeti, chef, etc.
class Collectors
  def initialize
    @cache = Cache.new(ENV['CACHE_FILE'])
    # TODO: Query database for each unique cluster name
    @template = ERB.new File.new('datastruct.erb').read, nil, '%'
  end

  # Public: Queries Ganeti by cluster to receive node information via the Ganeti
  #         RAPI. Stores the information in the file cache.
  def collect_ganeti(cluster)
    # for each cluster, append port number, endpoint, and query.
    uri = URI("https://#{cluster}.osuosl.bak:5080/2/instances?bulk=1")
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

        # To retrieve the node information, use cache.get and JSON.parse.
        # This will give you a ruby hash of the node information.
        # info = @cache.get(<node_name>)
        # time = @cache.get(<node_name> + ':datetime')

      rescue SocketError
        log.fatal "SocketError cannot connect to #{name}"
      end
    @cache.write
  end

  # meta-function used to check the databases
  def collect_db(db_type, host, user, password)
    case db_type
    when :mysql
      collect_mysql(host, user, password)
    when :postgres
      collect_postgres(host, user, password)
    else
      STDERR.puts "db_type `#{db_type}` is neither `:mysql` nor `:postgres`."
    end
  end

  def collect_mysql(host, user, password)
    # TODO Raise an error / print to stderr if something breaks?
    # Establish a connection to the database
    db = Sequel.connect("mysql://#{user}:#{password}@#{host}")

    # Run the magic statistics gathering query
    db.fetch("SELECT table_schema
                'DB Name',
              cast(round(sum( data_length + index_length ) , 1) as binary)
                'Data Base Size in Bytes'
              FROM information_schema.TABLES
              GROUP BY table_schema") do |var|
      @cache.set(var[:"DB Name"], var[:"Data Base Size in Bytes"])
      @cache.set(var[:"DB Name"] + ':datetime', Time.new.inspect)
    end
    @cache.write
  end

  def collect_postgres(host, user, password)
    # Will look similar to collect_mysql
  end
end
