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
required. IAM's password for the database is set to ``toor`` by default.

#. ``BASE_DIR`` and ``APP_DIR`` - These two env vars are set to the same
path which directs to the app's base directory, currently ``/data/code``

#. ``TEST_MYSQL_DB`` - Is used to test IAM by allowing the db collector spec to
run. This var should be set to true.

#. ``DB_COLLECTOR_DBS`` - This is the database that the collector spec queries.

The following four env vars specify how the spec interacts with the docker mysql:

#. ``TEST_MYSQL_ROOT_PASS`` - The password for root. Set to ``toor`` by default.

#. ``TEST_MYSQL_HOST`` - The host for the database. Set to ``testing-mysql`` by
default.

#. ``TEST_MYSQL_USER`` - The name of the user. Set to ``bob`` by default.

#. ``TEST_MYSQL_USER_PASS`` - The password for the user. Set to ``test`` by
default. 

Environment
-----------

In the ``environment.rb`` file, it sets the paths for files such as the
cachefile, logfile, and db_url. It then checks if things like the actual databse
from the ``DB_URL`` exists or if ``DB_COLLECTOR_DBS`` is set. If the
``ENV[DB_COLLECTOR_DBS]`` variable has not been set in the ``app.env.dist``, then
the database declared in the ``config.ru`` is used in it's place.
