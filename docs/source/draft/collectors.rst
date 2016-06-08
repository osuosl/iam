.. _draft_collectors:

Draft Collectors
================

IAM Collectors query various configuration management APIs and store all
relevant data in a key-value store. We currently use Redis to do this, but are
considering memcache as another option.

.. contents::


Structure
---------

The ``Collectors`` class is defined in the ``collectors.rb`` file in the
project's root directory.

Initialize Method
~~~~~~~~~~~~~~~~~

The ``initialize`` method sets a ``redis`` cache variable so each collection
method can store data on the same cache instance. ``initialize`` also currently
defines a list of ganeti clusters to query. Finally, a template file is read
that contains the data structure with which we will store our cached data.

TODO: Query our database for each unique cluster name. This is low priority
      because management only bills for the cluster named ``ganeti``.

Collect Methods
~~~~~~~~~~~~~~~

The remaining methods are ``collect_<api>`` methods. These methods complete a
number of tasks to query the relevant API and store it in the database.

#. For each node/API endpoint/cluster to query:

   #. Construct the fqdn and create a URI from it.

      .. code-block:: ruby

         uri = URI(<fqdn>)

   #. Open a connection to the fqdn, an easy way to do this is:

      .. code-block:: ruby

         Net::HTTP.start(uri.host,    uri.port,
                         use_ssl:     uri.scheme == 'https',
                         verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|

   #. Send your request to the URI

      .. code-block:: ruby

         response = http.request Net::HTTP::Get.new uri

   #. Parse the response and store it into variables **that are defined in the
      data structure template**, ``datastruct.rb``. This is necessary so that
      you can create a binding in the next step. For example:

      .. code-block:: ruby

         node_name = node['name'] || 'unknown'

      stores the response's ``name`` field in ``node_name`` if it exists. If it
      does not exist, an ``'unknown'`` string is stored. This is important
      because ``nil`` values break the template.

   #. Store the result of a template binding to the cache at the name of the
      resource. Also store the datetime of the query at ``<name>:datetime``. In
      Redis, it looks like this:

      .. code-block:: ruby

         @redis.mset(<resource_name>, @template.result(binding),
                     <resource_name> + ':datetime', Time.new.inspect)

#. Rescue any socket errors (``SocketError``) and log the information. The
   collector should not fail because of one socket error.

