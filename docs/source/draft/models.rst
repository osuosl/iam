.. _draft_models:

Draft Models
============

The following database models are being considered in the implementing IAM:

.. contents::

.. note::

    All fields are 'Unique' within their given table.


Clients
--------

Clients are stored in the database with the given schema.

========== ======== ====== ====================================================
Field      Type     Unique Description
---------- -------- ------ ----------------------------------------------------
id         integer  true   Client's Unique ID.
name       string   true   Client's human readable name.
========== ======== ====== ====================================================


Projects
--------

Projects are stored in the database with the following schema:

============= ================ ====== =========================================
Field         Type             Unique Description
------------- ---------------- ------ -----------------------------------------
id            integer          true   Project's unique ID.
name          string           true   Project's human readable name.
client_id     foreign key      false  Client which owns this project.
resources     serialized list  false  For example: "cpu,ftp,db"
============= ================ ====== =========================================


Resources
---------

A given table for ``resourceX`` (e.g., ``node``, ``DB``, ``FTP``) will have the
following fields of the given type:

=========================== =========== ======= =================================
Field                       Type        Unique  Description
--------------------------- ----------- ------- ---------------------------------
id                          integer     true    Resources unique ID.
project_id                  foreign key false   Project which owns this resource.
resources_specific_field_1  var         false   Any specific metadata about
resources_specific_field_2  var         false   |
cluster                     string      false   Specifies ganeti cluster fqdn if applicable, null if not
...etc                      var         false   |
=========================== =========== ======= =================================


Measurements
------------

A given table for ``measurementX`` (e.g., ``CPU``, ``Memory``, ``Bandwidth``)
will have the following fields of the given type:

=============== ============ ======= ===================================================
Field           Type         Unique  Description
--------------- ------------ ------- ---------------------------------------------------
id              integer      true    Measurement unique id.
resource_id     foreign key  false   Resource which owns this measurement.
timestamp       datetime     false   Time the measurement was recorded.
value           float        false   Measurement value (in units dictated by the plugin)
=============== ============ ======= ===================================================


Plugins
-------

Plugins are registered in the database with the following schema:

================== ======= ====== =================================================================
Field              Type    Unique Description
------------------ ------- ------ -----------------------------------------------------------------
id                 integer true   Plugin unique id.
name               string  true   Plugin unique name.
measurement_table  string  false  Measurements table which the plugin writes to.
measurement_units  string  false  Units plugin reports it's data in.
resource_type      string  false  The type of resource the plugin reports on (e.g., 'node' or 'db')
================== ======= ====== =================================================================
