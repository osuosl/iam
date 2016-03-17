.. _draft_design:

Draft Design
============

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

#. Query our Resources table to find all unique `cluster` fqdns. If the
   `cluster` field is `null`, the node is not a ganeti VM.

#. Run a GET request against each
   `<cluster-fqdn>/<ganeti-version>/instances?bulk=1`

#. Store the returned JSON in a cache such as redis
   (http://redis.io/documentation) with the cluster name and a datetime.

Metrics Gathering
~~~~~~~~~~~~~~~~~

#. A list of all resources is collected with their corresponding measurements
   (CPU, Memory, Bandwidth, etc).

#. **if** the node's `cluster` field is **not** `null`, query our cache at
   `cluster-fqdn` for the relevant measurements.

   **else** for each measurement corresponding to each resource, that
   measurement's plugin is called.

   The plugin is given a resource id and automatically polls the resource for
   relevant data and stores that data in the correct table.

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
