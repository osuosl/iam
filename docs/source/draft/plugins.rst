.. _draft_plugins:

Draft Plugins
=============

IAM Plugins are the first class tool which collect and report data.

.. contents::


Structure
---------

Each plugin consists of the plugin object and the register method.


Register Method
~~~~~~~~~~~~~~~

The register method is called automatically when a plugin is added to IAM.

The job of the helper class is to make IAM aware of the plugin so that it can
be called when appropriate.

An example helper class would look like this:

.. code-block:: ruby

    def register()
        model = { plugin_name:       CPU,   # Name of the Plugin Object
                  measurement_table: CPU,   # Table to write measurements to
                  measurement_units: cpus,  # Reported units (N cpus)
                  resource_type:     node } # Type of resouce this plugin is used on.
    end


Plugin Object
~~~~~~~~~~~~~

The plugin object is what actually collects and reports data.

This is the general structure of a plugin:

.. code-block:: ruby

    Class CPU < Plugin

        def collect(resource_id, resource_type)
            @id   = resource_id
            @type = resource_type
            [...]
        end


        def report(resource_id, resource_type)
            @id   = resoruce_id
            @type = resource_type
            [...]
        end


        def _helper_method_1(var1, var2, ...)
            [...]
        end
    end

Notice that ``Class CPU`` is a subclass of ``Class Plugin``. This parent class
provides helper methods to make building a plugin as easy as possible.

The ``collect`` method is passed a ``resource_type`` parameter that identifies
how the resource is managed. For example, if ``resource_type`` indicates that
the resource is a Ganeti VM, then the resource information will be gathered
by querying the cache data structure.
