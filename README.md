# Invoicing and Metrics


## Goal

Collect billable metrics from projects hosted at the OSL.


## Status

Design and research phase - 1-27-16


## Development With `docker`

Invoicing and Metric (iam) is developed in `docker` using `docker-compose`:

- `docker` version 1.10.3
- `docker-compose` version 1.6.2.

Set the `COMPOSE_PROJECT_NAME` variable. This name-spaces your containers
so multiple users can develop independently on the same machine.

```
$ echo "export COMPOSE_PROJECT_NAME=$USER" >> ~/.bashrc
$ source ~/.bashrc # replace `.bashrc` with your shell's config file.
```


**Note**: If you have not set the `docker` group settings correctly you will
need to add the above line to the `root` user's `.bashrc` or configure your
host machine appropriately (or do things in a Virtual Machine).

Copy `dockerfiles/app.env.dist` to `dockerfiles/app.env`. There aren't any
secrets in `app.env.dist` but you can put secret environment variables in
`app.env` as it is not tracked by git.

Next build the containers necessary for development.

```
$ docker-compose build
[... docker building output ...]
```

If you just want to run the application do the following:

```
$ docker-compose up
[... docker-compose output seperated by color ...]
```

If you want to write code and run commands in a dev shell run

```
$ docker-compose run --service-ports dev bash
```

### Docker Files and Env Variables

```
docker-compose.yml    # Specifies services to be run.
dockerfiles/          # Houses all docker related files (except docker-compose.yml).
├── app               # Specifies the app/dev docker containers.
├── app.env           # Specifies static environment variables for the app container.
├── app.env.dist
├── centos-ruby       # Specifies the base container for the app image.
│                     # Pulled from dockerhub as a static container.
├── cleanup.sh        # Changes file permissions from root to $USER on shell exit.
│                     # Also deletes Gemfile.lock to avoid weird versioning bugs.
└── startup.sh        # general statup needs (dynamic env vars, etc).
```

Some Environment variables are set:

```
$CACHE_FILE         # Location of temporary cache file.
$POSTGRES_PORT      # The host on which the linked postgres container can be reached
$POSTGRES_USER      # postgres's user
$POSTGRES_PASSWORD  # postgres's user's password
```

If the postgres environment variables are not taking into effect:

```
$ docker-compose kill
$ docker-compose rm
```

To access the postgres DB from a workstation:

```
$ docker-compose run dev psql -h postgres -U < postgres username from dockerfiles/app.env >
```

or from inside the container:

```
$ psql -h postgres -U $POSTGRES_USER
```

### Running tests

```
$ docker-compose run --service-ports --rm dev bash
[root@9eea4caf7740 code]# rake spec
... tests running ...
Finished in 0.1669 seconds (files took 0.36978 seconds to load)
60 examples, 0 failures
[root@9eea4caf7740 code]# rake
Migrating to latest
/usr/local/bin/ruby app.rb
== Sinatra (v1.4.7) has taken the stage on 4567 for development with backup from Thin
Thin web server (v1.7.0 codename Dunder Mifflin)
Maximum connections set to 1024
Listening on localhost:4567, CTRL+C to stop
```

You may be prompted to `bundle install`.

## Development Without `docker`

If you do not want to install `docker` and `docker-copmose` and instead want to
run the service natively you can try installing the following packages:

- `sqlite-devel`
- `postgresql`
- `postgresql-devel`
- `ruby-2.3.0` and `gem`
- `gem install bundle`

Unfortunately we are not able to help with getting `postgresql` up and running
on your system, but there's plenty of tutorials that *can* help with that.

If you do have problems installing your system, try reading the
`dockerfiles/app` file to see how the docker environment is created (it's
basically a bash script). If you're still having problems setting up your
environment please feel free to make an issue and we'll help out.

### Setting up the Environment

You'll need to add a few environment variables to your computer. I suggest
adding the following the lines to your `.bashrc`:

```
export POSTGRES_PASSWORD=changeme   # your postgres password
export CACHE_FILE=/tmp/iam-cache    # Where you want to save the cache file to
export POSTGRES_HOST=127.0.0.1      # Whatever your postgres host ip address is
```

and reload your shell with `source ~/.bashrc`.

### Running tests

```
$ rake spec
[... tests running ...]
Finished in 0.1669 seconds (files took 0.36978 seconds to load)
60 examples, 0 failures
$ rake
Migrating to latest
/usr/local/bin/ruby app.rb
== Sinatra (v1.4.7) has taken the stage on 4567 for development with backup from Thin
Thin web server (v1.7.0 codename Dunder Mifflin)
Maximum connections set to 1024
Listening on localhost:4567, CTRL+C to stop
```

### Troubleshooting

**Problem:** When you try to run the app with `rake spec` or `ruby app.rb` and
receive errors like:

```
Could not find parser-2.3.0.7 in any of the sources
Run `bundle install` to install missing gems.
```

This represents that your docker image has gem dependencies that are out of
date.

**To fix:** Run `docker-compose build --no-cache`. This will rebuild the
container and rerun the command `bundle install` to refresh all the gems

**Problem:** ``docker`` or ``docker-compose`` does not work, or you get an
error along the lines of

```
$ docker-compose run dev bash
Could not find file <some file>
[root@9eea4caf7740 code]#
```

or you might get something like `too many symbolic links`.

Just `exit` the docker environment and run

```
$ sudo systemctl restart docker
```

to restart the docker service; this fixes the above problem 99% of the time.

If you have any other issues not mentioned in this README, take a look at our
`docs`. If you still don't see anything that answers your questions in the docs
make an issue on this repository and we'll try to help out.
