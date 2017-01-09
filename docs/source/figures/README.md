# DOT Figures

`dot` is a tool for producing a graph described in a given `.dot` file. We use
it to create data-flow diagrams and anything else where a technical graph would
help get the idea across.

The all figures described by `<filename>.dot` files in the `figures/` directory
are automatically built in `<filename>.png` and `<filename>.svg` format and
placed in the `_static`.

To install the `dot` utility to build the graphics in the docs. Otherwise it
will fail to build updated versions of the graphics.

## Example:

The following will build and produce a fairly useful graph describing key
components of IAM's data flow from API call to user report.

```
digraph "IaM Dataflow" {
    TITLE
    "ohai"   -> disk_usage -> "ohai_collect()"   -> H_STORE
    "Ganeti" -> disk_size  -> "ganeti_collect()" -> H_STORE
    H_STORE -> "Plugin.store()" -> DB -> "Plugin.report()" -> {CSV,HTML,JSON}

    TITLE              [shape=box      ,label="\G"]
    "ohai"             [shape=plaintext,tooltip="External API Call"]
    "Ganeti"           [shape=plaintext,tooltip="External API Call"]
    disk_usage         [shape=ellipse  ,tooltip="API return field"]
    disk_size          [shape=ellipse  ,tooltip="API return field"]
    "ohai_collect()"   [shape=diamond  ,tooltip="Plugin method for recording data in the database."]
    "ganeti_collect()" [shape=diamond  ,tooltip="Plugin method for reporting data from the database to the user."]
    H_STORE            [shape=box3d    ,tooltip="Postgres Key:Value Store"]
    "Plugin.store()"   [shape=diamond  ,tooltip="Plugin method for recording data in the database."]
    "Plugin.report()"  [shape=diamond  ,tooltip="Plugin method for reporting data from the database to the user."]
    DB                 [shape=box3d    ,tooltip="Postgres Backed Database"]
    CSV                [shape=plaintext,tooltip="Output Format"]
    HTML               [shape=plaintext,tooltip="Output Format"]
    JSON               [shape=plaintext,tooltip="Output Format"]
}
```

The format is pretty simple. The bare minimum is you need a `graph <name> { }`
and preferably at least one object inside of it. The `diagraph` adds the arrows
to show direction. The `->` is the arrow.

`dot` will automatically sort, place, and resize your objects in the final
product, but you do have a lot of influence over what that looks like by
setting object attributes.

Note:

- Shapes are used to to show similar types of objects. In this example:
  - `plaintext` objects are things going to or coming from the outside world.
  - `ellipse` objects are pieces of data.
  - `diamond` objects are functions or methods.
  - `box3d` objects are external services for storing / retrieving data.
- Tooltips are used for adding context to an object. They are only visible when
  one mouses over an object in the `svg` file output.

For more information read the manual for `dot` via `man dot` in your terminal.
Or use a search engine if that's how you do you.
