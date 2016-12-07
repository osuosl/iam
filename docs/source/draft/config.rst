.. _draft_config:

Config and ENV vars
===================

The following document outlines the usage of the config and ENV vars
in basic terms.

.. contents::


Structure
---------

The config and ENV vars are defined in the ``app.env.dist`` file in the
project's root directory. These variables define pathways, databases,
and passwords for the IAM to use in initialization process.

ENV Vars
--------



Environment
-----------

In the ``environment.rb`` file, it sets the paths for files such as the
cachefile, logfile, and db_url. It then checks if things like the actual databse
from the ``DB_URL`` exists or if ``DB_COLLECTOR_DBS`` is set. If the
``ENV[DB_COLLECTOR_DBS]`` variable has not be set in the ``app.env.dist``, then
a dummy database is used in it's place.
