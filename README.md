# Invoicing and Metrics


## Goal

Collect billable metrics from projects hosted at the OSL.


## Status

Design and research phase - 1-27-16


## Development With `docker`

Invoicing and Metrics (iam) is developed in `docker` using `docker-compose`:

- `docker` version 1.10.3
- `docker-compose` version 1.6.2.

**If you are working on a shared workstation:** Set the `COMPOSE_PROJECT_NAME`
variable. This name-spaces your containers so multiple users can develop
independently on the same machine.

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

**Note**: When you make changes to `app.env` be sure they are reflected in
`app.env.dist` otherwise they will not be committed and people will have a hard
time testing your changes in a pull request.

Next build the containers necessary for development.

```
$ docker-compose build
[... docker building output ...]
```

To start the application or log into the application's development environment
run the following:

```
$ docker-compose run --rm --service-ports dev bash
Starting username_testing-mysql_1
Starting username_testing-psql_1
[root@e0c038378442 code]# rake    # this runs the application
Migrating to latest
[...]
Listening on 0.0.0.0:4567, CTRL+C to stop
[root@e0c038378442 code]# rake spec   # this runs the tests
[...]
Finished in 15.6 seconds (files took 0.93519 seconds to load)
## examples, ## failures
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

**Some Environment variables are set:**

```
DATABASE_URL        # The path for a sqlite database file for testing.
CACHE_FILE          # The path for the application's cache.
POSTGRES_USER       # Default user for the postgres host.
POSTGRES_PASSWORD   # Default user's password for the postgres host.
POSTGRES_DB         # Default database for the postgres host.
MYSQL_ROOT_PASSWORD # Root password for the mysql host.
MYSQL_USER          # Default user for the myql host.
MYSQL_PASSWORD      # Default user's password for the mysql host.
MYSQL_DATABASE      # Default database for the mysql host.
```

**If changes were made to the `docker-compose.yml` or `dockerfiles/app.env` or
you just need to wipe away your docker environment as it is, run:**

```
$ docker-compose kill
$ docker-compose rm
```

### Running tests

```
$ docker-compose up dev
[...]
dev_1     | [...]
dev_1     | Finished in 15.66 seconds (files took 0.92976 seconds to load)
dev_1     | ## examples, ## failures
username_dev_1 exited with code 0
```

**Note** This will auto-magically do the following:
- Build the containers if they have not yet been built.
- Start the database hosts used in the tests.
- Wait for said DB hosts to be ready to test with.
- Run the tests, printing the output as it goes.
- Stop the container and put you back on your workstation shell once done.

----

## Development Without `docker`

If you do not want to / cannot install `docker` and `docker-compose` and
instead want to run the service natively you can try installing the following
packages with your system package manager:

- `git`
- `sqlite-devel`
- `postgresql`
- `postgresql-devel`
- `ruby-2.3.0` and `gem`
- `mysql`
- `mysql-devel`

**Note**: You may need to install `ruby-2.3.0` from source. [Here is a page
that can help you install
ruby-2.3.0](https://www.ruby-lang.org/en/documentation/installation/). This may
require the installation of the following dependencies:

- `gcc` and `gcc-c++`
- `openssl` and `openssl-devel`
- `zlib-devel`

**Note:** Using Ruby's `gem` package manager install `bundle`.

Next, clone the repo. Run this command in the directory that you use to store
your source code and the Ruby dependencies.

```
$ git clone https://github.com/osuosl/iam.git /home/myuser/my-source-dir/iam
$ cd /home/myuser/my-source-dir/iam/
[~/my-source-dir/iam] $ bundle install
[... yay bundle! ...]
```

**Note** Unfortunately we are not able to help with getting `postgresql` and
`mysql` up and running on your system, but there's plenty of tutorials that
*can* help with that. For instance, [the PostgreSQL
documentation](https://www.postgresql.org/docs/9.2/static/index.html) and [the MySQL
documentation](http://dev.mysql.com/doc/refman/5.7/en/windows-installation.html).

If you have problems setting up IaM try the following:

- Read the `dockerfiles/app` file to see how we setup the docker environments,
  which are known to work. This may require some digging, but should give you a
  starting point.
- Make an issue on this repo! We will try to help you get setup and/or direct
  you to some helpful documentation.

### Setting up the Environment

You'll need to add a few environment variables to your computer. Add the
following the lines to your `.bashrc`:

```
export POSTGRES_PASSWORD=changeme   # your postgres password
export CACHE_FILE=/tmp/iam-cache    # Where you want to save the cache file to
export POSTGRES_HOST=127.0.0.1      # Whatever your postgres host ip address is
```

and reload your shell with `source ~/.bashrc`.

### Running tests

```
[~/my-source-dir/iam] $ rake spec
[... tests running ...]
Finished in 0.1669 seconds (files took 0.36978 seconds to load)
60 examples, 0 failures
[~/my-source-dir/iam] $ rake
Migrating to latest
/usr/local/bin/ruby app.rb
== Sinatra (v1.4.7) has taken the stage on 4567 for development with backup from Thin
Thin web server (v1.7.0 codename Dunder Mifflin)
Maximum connections set to 1024
Listening on localhost:4567, CTRL+C to stop
```

## Troubleshooting

**Problem:** *Running the app with `rake spec` or `ruby app.rb` you receive
errors like*:

```
Could not find parser-2.3.0.7 in any of the sources
Run `bundle install` to install missing gems.
```

This means that your Docker image has gem dependencies that are out of
date.

**To fix:** Run
```
docker-compose build --no-cache
```

This will rebuild the container and rerun the command `bundle install` to
refresh all the gems.

If you are not running in a docker container, just run `bundle install` like
the error says.

**Problem:** *``docker`` or ``docker-compose`` does not work, or you get an
error along the lines of:*

```
$ docker-compose run dev bash
Could not find file <some file>
[root@9eea4caf7740 code]#
```

*or you might get something like `too many symbolic links`*.

**To Fix:** Just `exit` the docker environment and run

```
$ sudo systemctl restart docker
```

to restart the docker service; this fixes the above problem 99% of the time.

If you have any other issues not mentioned in this README, take a look at our
`docs`. If you still don't see anything that answers your questions in the docs
make an issue on this repository and we'll try to help out.

**Problem:**: *The following output occurs when you run `rake spec` or try to
reach a database server:*

```
[... one long line ...]
/usr/local/lib/ruby/gems/2.3.0/gems/sequel-4.33.0/lib/sequel/adapters/mysql.rb:102:in `real_connect': Mysql::Error: Can't connect to MySQL server on 'testing-mysql' (111) (Sequel::DatabaseConnectionError)
    from /usr/local/lib/ruby/gems/2.3.0/gems/sequel-4.33.0/lib/sequel/adapters/mysql.rb:102:in `connect'
[... many lines of traceback ...]
```

This could mean one of a few things:

1. Your database host is not yet ready to receive connections.
2. Your environment is not yet setup correctly.

**To Fix:**

1. Wait up to a minute and try again. The host will eventually start and you
will be able to complete your task.
2. If you have already waited and the same error occurs do the following:
  - Verify that `dockerfiles/app.env` is up to date (and
    `dockerfiles/app.env.dist`)
  - Rebuild your docker containers by logging out of the dev container and
    running the following commands on your workstation in the `iam` directory
    before picking up where you left off:

```
$ docker-compose kill
$ docker-compose rm
$ docker-compose build
```
