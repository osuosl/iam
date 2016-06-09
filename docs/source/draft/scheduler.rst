.. _draft_scheduler:

Draft Scheduler
===============

IAM uses `rufus scheduler`_ to schedule the various tasks that need to run at
certain times. These tasks include running the collectors'``collect_<api>``
methods and the plugins' ``store`` methods.

Collect Task
------------

By our application design, we collect information with our ``collect_<api>``
methods every 30 minutes. Those methods store the various API returns in a
common data structure before storing them in a cache. We are currently using
Redis as our caching system.

Store Task
----------

Offset by 15 minutes, and running every 30 minutes, all plugin ``store``
methods are called. These methods take all the data out of the cache and store
them in our database. For this task, it is necessary to ```rake plugins```
as the first step in order to find all the plugins and store them in our
plugins table.

.. _rufus scheduler: https://github.com/jmettraux/rufus-scheduler
