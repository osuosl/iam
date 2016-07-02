.. _implementation_docs:

IaM Implementation
==================

This document includes writeups about each of the moving parts of Invoicing and
Metrics and how they work. The following table of contents is roughly outlined
like the repository is.

This docuemnt is aimed at developers who intend to contribute and want to get
aquainted with the code.

.. warning::

    This document is not directly tied to the code and may (will) drift from
    the actual implementation. If something doesn't match up, contact the
    developers.


.. contents::


app.rb
------

datastructure.erb
-----------------

docker-compose.yml
------------------

dockerfiles/
------------

app
~~~

app.env
~~~~~~~

app.env.dist
~~~~~~~~~~~~

centos~ruby
~~~~~~~~~~~

cleanup.sh
~~~~~~~~~~

startup.sh
~~~~~~~~~~

environment.rb
~~~~~~~~~~~~~~

Gemfile
-------

lib/
----

BasePlugin/
~~~~~~~~~~~

migrations
++++++++++

plugin.rb
+++++++++

spec.rb
+++++++

util.rb
~~~~~~~

LICENSE
-------

migrations/
-----------

models.rb
---------

plugins/
--------

DiskTemplate/
~~~~~~~~~~~~~

migrations/
+++++++++++

plugin.rb
+++++++++

spec.rb
+++++++

DiskSize/
~~~~~~~~~

migrations/
+++++++++++

plugin.rb
+++++++++

spec.rb
+++++++

VCPUCount/
~~~~~~~~~~

migrations/
+++++++++++

plugin.rb
+++++++++

spec.rb
+++++++

Rakefile
--------

README.md
---------

routes/
-------

clients.rb
~~~~~~~~~~

main.rb
~~~~~~~

projects.rb
~~~~~~~~~~~

scheduler.rb
------------

scripts/
--------

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
