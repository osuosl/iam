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

The env vars that are currently in develop are:

#. ``DB_URL`` - The path to the database that IAM uses to run

#. ``CACHE_PATH`` - Is set to ``cachefile`` which gets set in
``environment.rb`` where it determines if IAM is currently in testing mode. If
it is, then ``cachefile`` gets set to ``testcache``.

#. ``LOG_FILE_PATH`` - Is set to ``logfile`` which is the file that contains all
the logs from the app.

#. ``MYSQL_ROOT_PASSWORD`` - The mysql database requires that either a password
is set or that the database's settings are set so that there is no password
required. IAM does set a password for the database which is currently set to
``toor``.

#. ``BASE_DIR`` and ``APP_DIR`` - These two env vars are set to the same
path which directs to the app's base directory, currently ``/data/code``

#. ``TEST_MYSQL_DB`` - Is used to test IAM by allowing the db collector spec to
run. This var should be set to true.



Environment
-----------

In the ``environment.rb`` file, it sets the paths for files such as the
cachefile, logfile, and db_url. It then checks if things like the actual databse
from the ``DB_URL`` exists or if ``DB_COLLECTOR_DBS`` is set. If the
``ENV[DB_COLLECTOR_DBS]`` variablthee has not be set in the ``app.env.dist``, then
a dummy database is used in it's place.
