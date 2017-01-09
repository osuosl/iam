.. _draft_collectors:

Draft Collectors
================

IAM Collectors query various configuration management APIs and resources
(including databases) and store all relevant data in a key-value store. We
currently use a hacked together file-based cacher ``Cache`` to do this, but are
considering file storage as another option.

.. contents::


Structure
---------

The ``Collectors`` class is defined in the ``collectors.rb`` file in the
project's root directory.

Initialize Method
~~~~~~~~~~~~~~~~~

The ``initialize`` method creates a shared ``Cache`` object to cache data so
each collection method can store data on the same cache instance.
``initialize`` also currently defines a list of ganeti clusters to query.
Finally, a template file is read that contains the data structure with which we
will store our cached data.

.. todo::

   Query our database for each unique cluster name. This is low priority because
   management only bills for the cluster named ``ganeti``.

Collect Methods
~~~~~~~~~~~~~~~

The remaining methods are ``collect_<resource>`` methods. These methods must
complete a number of tasks to query the resource for measurement data and store
it in the database.

#. For each node/resource fqdn, connect to the resource and perform any other
   required processing methods. For example, if you are getting information
   from a MySQL database this step includes the relevant SQL queries to query
   the data you need.

#. Parse the response and store it into variables **that are defined in the data
   structure template**, ``datastruct.rb``. This is necessary so that you can
   create a binding with the template before storing in the cache. For example:

   .. code-block:: ruby

      node_name = node['name'] || 'unknown'

  stores the ``node['name']`` field in the ``node_name`` variable that is
  defined in the template. If ``node['name']`` does not exist, the string
  ``'unknown'`` is stored. This is important because ``nil`` values break the
  template.

#. Store the result of a binding to the cache at the name of the resource. Also
   store the datetime of the query at ``<name>:datetime``. With Cache, it looks
   like this:

   .. code-block:: ruby

      @cache.set(<resource_name>, @template.result(binding))
      @cache.set(<resource_name> + ':datetime', Time.new.inspect)
      @cache.write

#. Rescue any socket errors (``SocketError``) and log the information. The
   collector should not fail because of one socket error.

Schedule
--------

All collect methods must be scheduled in the ``rufus`` scheduler in
``scheduler.rb``. These methods are scheduled every 30 minutes, offset from the
plugin methods by 15 minutes.

To add a new method to the collect task, simply add another line at the end of
the block:

.. code-block:: ruby

   collector.<new method name>
