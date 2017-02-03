.. _draft_config:

Config and Environment Variables
================================

The following document outlines the usage of the config and environment
variables in basic terms.

.. contents::

Structure
---------

The config and ENV vars are defined in the ``app.env.dist`` file in the
project's root directory. These variables define pathways, databases,
and passwords for the IAM to use in initialization process.

Environment Variables
---------------------

The environment variables that are currently in develop are:

- ``DB_URL`` - This is the path to the database that IAM uses to run. This
  variable is required for the production app settings.

- ``CACHE_PATH`` - Is set to ``cachefile`` which gets set in
  ``environment.rb`` where it determines if IAM is currently in testing mode. If
  it is, then ``cachefile`` gets set to ``testcache``. This variable is required
  for the production app settings.

- ``LOG_FILE_PATH`` - This is set to ``logfile`` which is the file that contains
  all the logs from the app. This variable is required for the production app
  settings.

- ``MYSQL_ROOT_PASSWORD`` - The mysql database requires that either a password
  is set or that the database's settings are set so that there is no password
  required. IAM's password for the database is set to ``toor`` by default. This
  variable is required for the docker dev env settings that are used for
  testing.

- ``BASE_DIR`` and ``APP_DIR`` - These environment variables are set to the same
  path which directs to the app's base directory, currently ``/data/code``.
  These variables are required for the production settings.

- ``TEST_MYSQL_DB`` - Is used to test IAM by allowing the db collector test
  suite to run. This var should be set to true.

- ``DB_COLLECTOR_DBS`` - This is the database that the collector test suite
  queries.

The following four environment variables specify how the spec interacts with the
docker mysql:

- ``TEST_MYSQL_ROOT_PASS`` - This is the password for root. It is set to
  ``toor`` by default.

- ``TEST_MYSQL_HOST`` - This is the host for the database. Set to
  ``testing-mysql`` by default.

- ``TEST_MYSQL_USER`` - This is the name of the user. Set to ``bob`` by default.

- ``TEST_MYSQL_USER_PASS`` - This is the password for the user. Set to ``test``
  by default.

Environment
-----------

In the environment.rb file, it sets the paths for files such as the
cachefile, logfile, and db_url. It then checks if things like the actual
database from the ``DB_URL`` exists or if ``DB_COLLECTOR_DBS`` is set. If the
``ENV[DB_COLLECTOR_DBS]`` variable has not been set in the ``app.env.dist``,
then the database declared in the config.ru is used in it's place.

App.env Files
-------------

The app.env and app.env.dist files contain the environment variables for the
docker development process. The .dist file contains environment variables with
general passwords and users for the databases. The app.env.dist file is copied
into the app.env file which is used by docker and once copied into app.env, the
real passwords and users are used in the variables.

Env.yml-dist
------------

The env.yaml-dist file contains variables used during the production of the app,
and is not for the use of development.
