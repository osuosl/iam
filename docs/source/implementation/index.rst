.. _implementation_docs:

IaM Implementation
==================

This document includes write-ups about each of the moving parts of Invoicing and
Metrics and how they work. The following table of contents is roughly outlined
like the repository is.

This document is aimed at developers who intend to contribute and want to get
acquainted with the code.

.. warning::

    This document is not directly tied to the code and may (will) drift from
    the actual implementation. If something doesn't match up, contact the
    developers.


.. contents::


app.rb
------

The core of IaM's Sinatra Application [`SinatraRB Docs`_].

The application is setup in ``class IaM``, which inherits from the Sinatra class.
In the class the plugins and routes are imported and the ``Sinatra::*Routes``
are registered.

At the end of this class the application is run. When you run ``ruby app.rb``
in the `development environment`_ you should get the following output:

.. code-block:: text

    [root@f3438e579bd8 code]# ruby app.rb
    == Sinatra (v1.4.7) has taken the stage on 4567 for development with backup from Thin
    Thin web server (v1.6.4 codename Gob Bluth)
    Maximum connections set to 1024
    Listening on localhost:4567, CTRL+C to stop

.. _SinatraRB Docs: http://www.sinatrarb.com/intro.html

datastructure.erb
-----------------

Describes how data is stored in our cache [`cache docs`_]. Data is take form
the Ganeti API and processed (stripped-down) so the plugins [`plugins docs`_]
can easily grab the data they need from the cache.

.. _development environment:

docker-compose.yml
------------------

We use ``docker`` [`docker docs`_] with ``docker-compose`` [`docker compose
docs`_] for our development environment on IaM. This allows us to isolate our
development environment from our workstations. If you have any experience with
docker and docker-compose most of our environment should be pretty easy to
figure out. If you don't have that luxury here's a quick rundown of how our
docker work-flow is setup:

* ``docker-compose.yml`` declares three services:

  * **app**: Declares the base docker image including *which file to use to
    build the environment*, some *environment variables* to set, and which
    directory to set as the *current working directory*.
  * **dev**: Is *the actual container we use*. It declares *which command to run
    by default*, that it would like to be linked to **postgres**, which *ports to
    expose* when it's being run, and which *volumes to mount* to the running
    container.
  * **postgres**: is a container which allows us to test our code on an actual
    postures database.

We use these services to run our application with the following commands:

.. code-block:: text

    $ docker-compose build   # build the containers used by the app
    $ docker-compose run --service-ports --rm dev bash
        # this puts you into a shell in the development environment (like a VM)
        # from which you can run tests with `rake spec` or run the application
        # with `rake`.
        # To out of the development shell type `exit`

**When you make changes on your local workstation to the code in IaM the
changes show up in the development environment as well because the directory is
mounted in the running container**. This means you can edit code in your editor
of choice and run it in the final environment without having to setup IaM's
Ruby and PostgreSQL dependencies.

To learn more about our workflow in using docker-compose read our README which
should include details about how this gets used.

.. _docker docs: https://docs.docker.com/
.. _docker compose docs: https://docs.docker.com/compose/

dockerfiles/
------------

Stores all files related exclusively to the ``docker`` development environment.

app
~~~

The `Dockerfile`_ which describes how to build the development environment. It
inherits from the image described in `centos-ruby`_.

.. _Dockerfile: https://docs.docker.com/engine/reference/builder/

app.env
~~~~~~~

The static environment variables used in IaM including usernames, passwords,
and anything else which can be statically set.

.. note::

    This file is not tracked by ``git`` so it will not be committed to the
    repository when you make a change.

app.env.dist
~~~~~~~~~~~~

The distribution version of the above file. When you add a variable to
``app.env`` please add the same variable with a dummy value so it is relatively
easy to setup the development environment.

centos-ruby
~~~~~~~~~~~

The base for our application's docker image. This installs ``ruby-2.3.0`` in a
``centos-7`` image. The commands in this may be included in the ``app``
Dockerfile but building ruby from source is time consuming so instead we
inherit from an image we built.

cleanup.sh
~~~~~~~~~~

Triggered when you ``exit`` the development container from a ``bash`` session.
This changes the owner of your files in the ``iam`` directory to your user.
This was created because of some nuances in how ``docker`` works. It's
basically a hack and shouldn't get in your way.

startup.sh
~~~~~~~~~~

Sets dynamic environment variables including the IP address of the POSTGRES
database (linked via ``docker`` container linking).

environment.rb
~~~~~~~~~~~~~~

Does most of the pre-setup for IaM like library loading and setting config
variables. This is rarely touched and is mostly self explanatory.

Gemfile
-------

Dependencies for IaM based on which environment is being setup.  Analogous to
``requirements.txt`` from the ``python/pip`` world except it includes
functionality and isn't a plain flat-file.

lib/
----

Houses useful functionality and utilities used across multiple parts of the
code.

BasePlugin/
~~~~~~~~~~~

The base Plugin class used to de-duplicate code which was almost identical
across all plugins.

migrations
++++++++++

plugin.rb
+++++++++

Declares the ``BasePlugin`` class inherited by all other plugins. Uses
``@@variables`` declared in a new plugin's ``initialize`` method to
``register`` the new plugin and give the new plugin a ``report`` method.

Includes the declaration of a  ``TestingPlugin`` which more or less shows you
how to declare a new plugin and which variables to set in the ``initialize``
method so that ``BasPlugin`` can fulfill the ``register`` and ``report``
functionality of a new plugin automagically.

spec.rb
+++++++

Includes tests for ``BasePlugin`` by using the ``TestingPlugin`` class also
declared in the above ``plugin.rb``.

.. _cache docs:

util.rb
~~~~~~~

Declares the ``Cache`` class. When data is periodically collected from the
``Ganeti API`` it is stored in a cache. This cache was originally implemented
with ``Redis`` but we realized we could just as easily write one that uses a
Ruby Hash which gets saved to disk as JSON. This class is very simple keeping
in line with the *Keep It Simple Stupid* philosophy.

LICENSE
-------

`Apache 2.0`_ Woot woot!

  .. _Apache 2.0: https://en.wikipedia.org/wiki/Apache_License

migrations/
-----------

Migrations are used to make incremental changes to a database whenever your
schema changes. This directory contains the main migrations for our
application. [`migrations docs`_]

.. _migration docs: https://en.wikipedia.org/wiki/Schema_migration

models.rb
---------

Contains the base database models for our application including
- ``Client``
- ``Project``
- ``Plugin``
- ``NodeResource``

The database ORM we use is called ``sequel``. [ `sequel docs`_]

.. _sequel docs: http://sequel.jeremyevans.net/

.. _plugins docs:

plugins/
--------

Contain each of our plugins. Each plugin contains the same parts:

- A migrations directory to add the plugin's table to the database.
- ``plugin.rb`` which contains the variables to initialize the plugin's class
  and to ``store`` the plugin's data into the database.
- ``spec.rb`` which stores that plugin's tests. Those tests are included in the
  tests run by ``spec.rb``.

DiskTemplate/
~~~~~~~~~~~~~

Stores the type of disk a given Ganeti VM has. ``drbd`` for instance.

DiskSize/
~~~~~~~~~

Stores the size of a VM's disk in bytes.

VCPUCount/
~~~~~~~~~~

Stores the number of VCPU's a VM has allocated to it.

Rakefile
--------

Provides the following commands:

- ``rake run`` to run the application
- ``rake migrate`` to run the database migrations.
- ``rake rubocop`` to run the linter.
- ``rake spec`` to run the testing suite.

README.md
---------

Should include a description of the project, it's status, and instructions for
'getting started' with IaM.

routes/
-------

Stores the routes for IaM. These are what dictate when the browser goes to
``iamapp.ext/foo/bar/`` what gets returned. [`routes docs`_]

.. _routes docs: http://www.sinatrarb.com/intro.html#Routes

clients.rb
~~~~~~~~~~

Configure all views related to clients.

main.rb
~~~~~~~

Configures routes like the main page and error pages.

projects.rb
~~~~~~~~~~~

Configures routes related to projects.

scheduler.rb
------------

The scheduler uses the Ruby library ``rufus`` to schedule tasks like gathering
data into the cache and saving data into the database at regular intervals.
[`rufus docs`_]

.. _rufus docs: https://github.com/jmettraux/rufus-scheduler#rufus-scheduler

scripts/
--------

Our script are used for the ``docker`` development environment to start the
application with the correct dynamic environment variables set.

rake-app.sh
~~~~~~~~~~~

rake-dev.sh
~~~~~~~~~~~

spec/
-----

factories.rb
~~~~~~~~~~~~

models/
~~~~~~~

client_spec.rb
++++++++++++++

project_spec.rb
+++++++++++++++

routes/
~~~~~~~

app_spec.rb
+++++++++++

client_spec.rb
++++++++++++++

project_spec.rb
+++++++++++++++

spec_helper.rb
~~~~~~~~~~~~~~

util/
~~~~~

util_spec.rb
++++++++++++

views/
------

clients/
~~~~~~~~

edit.erb
++++++++

index.erb
+++++++++

show.erb
++++++++

layout.erb
~~~~~~~~~~

projects/
~~~~~~~~~

exit.erb
++++++++

index.erb
+++++++++

show.erb
++++++++
