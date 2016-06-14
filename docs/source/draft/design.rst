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

#. Store the returned JSON in a cache with the cluster name and a datetime.

The Cache
~~~~~~~~~

Our temporary cache is stored in a ``Cache`` object. The source code for this
can be found in ``lib/util.rb``. Basically all it does is:

* Read in a JSON key:value store into a Ruby hash.
* Write that hash to the cache file with the ``.write`` method.
* Provides the ``.get`` and ``.set`` methods.

K.I.S.S.

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


.. I'm not sure this will work so I'm commenting it out for now.

..  Pre-Processing Proof of Concept
..  -------------------------------

..  This is a simple ruby script to serve as a proof of concept for
..  pre-processing Ganeti clusters. The script stores the resulting JSON data
..  in the cache at ``<fqdn>`` and the datetime of the request at
..  ``<fqdn>:<datetime>``.

..  **TODO:** Query our database of resources for unique ganeti cluster fqdns
..  and iterate over those instead of the hard-coded fqdn list.

..  Try this out:

..  #. copy the below script into a file called ``rapi-interface.rb``.

..  #. run ``ruby rapi-interface.rb``

..  .. code-block:: ruby

..     require 'net/http'
..     require 'uri'
..     require 'openssl'
..     require 'json'

..     cache = Cache.new

..     # TODO: Query database for each unique cluster fqdn
..     # for each cluster fqdn, append port number, endpoint, and query
..     fqdn = ['ganeti-psf.osuosl.bak', 'ganeti-civicrm.osuosl.bak']
..     fqdn.each do |name|
..         endpoint = ':5080/2/instances'
..         query = '?bulk=1'
..         url = 'https://' + name + endpoint + query
..         uri = URI(url)

..         Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https',
..                         :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
..             # perform get request on full path.
..             request = Net::HTTP::Get.new uri
..             response = http.request request # Net::HTTPResponse object

..             # Store returned information in cache with datetime and cluster name
..             cache.set(name, response.body)
..             cache.set(name + ':datetime', Time.new.inspect)
..         end
..     end

..     # To retrieve the the cluster information, use cache.get and JSON.parse.
..     # This will give you a ruby hash of the cluster information.
..     #
..     # cluster_info = JSON.parse(cache.get("ganeti-psf.osuosl.bak"))
