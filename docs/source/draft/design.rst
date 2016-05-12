.. _draft_design:

Draft Design
============

.. figure:: /_static/dataflow.svg
    :target: /_static/dataflow.svg

The following document outlines the design of IAM in general terms.

.. contents::


Ownership
---------

There is a hierarchy of ownership which IAM is built around.

* The OSL has Clients (Drupal.org, Apache, etc)
* Clients have Projects (Debian mirroring, Softare builds, etc)
* Projects have Resources (Node, Database, FTP, etc)
* Resources have Measurements (CPU, RAM, Bandwidth, etc)

Data Collection
---------------

This is the general procedure for collecting data:

#. A job scheduler provokes IAM to collect data from all nodes every 30
   minutes.

    This can be provoked by Chef, Cron, Resque, whichever.

Pre-processing
~~~~~~~~~~~~~~

Pre-processing may be scheduled separately from the metrics gathering, likely
at least 15 minutes prior.

#. Query our Resources table to find all unique ``cluster`` fqdns. If the
   ``cluster`` field is ``null``, the node is not a ganeti VM.

#. Run a GET request against each
   ``<cluster-fqdn>/<ganeti-version>/instances?bulk=1``

#. Store the returned JSON in a cache such as redis
   (http://redis.io/documentation) with the cluster name and a datetime.

Metrics Gathering
~~~~~~~~~~~~~~~~~

#. A list of all resources is collected with their corresponding measurements
   (CPU, Memory, Bandwidth, etc).

#. For each measurement corresponding to each resource, that measurement's
   plugin is called.

   **if** the resource's ``cluster`` field is **not** ``null``, query our cache
   at ``cluster-fqdn`` for the relevant measurement.

   **else** poll the resource for the relevant data.

   Store the data in the correct table.

Data Reporting
--------------

This is the general procedure for collecting data:

#. IAM is given a client and a timeframe to report on (default: last 30 days).

#. A list of the client's project is collected.

#. A list of the project's resources (and associated measurements) is
   collected.

#. All data is collected from the measurements tables which match that
   client's resources.

#. This data is compiled into a generic object and returned to the user as a
   CSV, JSON object, or whatever they want really.

Pre-Processing Proof of Concept
-------------------------------

This is a simple ruby script to serve as a proof of concept for pre-processing
Ganeti clusters. The script stores the resulting JSON data in redis at
``<fqdn>`` and the datetime of the request at ``<fqdn>:<datetime>``.

**TODO:** Query our database of resources for unique ganeti cluster fqdns and
iterate over those instead of the hard-coded fqdn list.

Try this out:

#. copy the below script into a file called ``rapi-interface.rb``.

#. ``gem install redis``

#. install redis - http://redis.io/topics/quickstart

#. start redis in another terminal - http://redis.io/topics/quickstart under
   ``Starting Redis`` heading.

#. run ``ruby rapi-interface.rb``

#. cd to your installed redis source code - ``redis-stable/src/``.

#. run ``./redis-cli`` and try ``get ganeti-psf.osuosl.bak``. You should get a
   ton of JSON back. Alternatively you can try
   ``get ganeti-psf.osuosl.bak:datetime`` and you should get a datetime back.

.. code-block:: ruby

   require 'net/http'
   require 'uri'
   require 'openssl'
   require 'json'
   require 'redis'

   redis = Redis.new

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
       end
   end

   # To retrieve the the cluster information, use redis.get and JSON.parse. This
   # will give you a ruby hash of the cluster information.
   #
   # cluster_info = JSON.parse(redis.get("ganeti-psf.osuosl.bak"))
