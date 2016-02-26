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

    This can be provoked by Chef, Cron, whichever.

#. A list of all resources is collected with their corresponding measurements
   (CPU, Memory, Bandwidth, etc).

#. For each measurement corresponding to each resource, that measurement's
   plugin is called.

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
