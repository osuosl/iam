#Invoicing and Metrics


##Goal

Collect billable metrics from projects hosted at the OSL.


##Status

Design and research phase - 1-27-16

##Development (with Docker)

We use docker and docker-compose to develop becuase docker-compose will
automatically expose ports, mount volumes, and link containers; all of which is
super convenient.

First, set everything up.

1. Clone and cd into this repository.
2. Install and setup `docker` however best fits you.
3. Install `docker-compose`:

```
$ pip install --user docker-compose
```

**IMPORTANT**: Next copy dockerfiles/app.dist to dockerfiles/app and edit the
variables:

```
ENV USER     your_user_name
ENV PASSWORD your_container_password
ENV UID      your_local_uid
```

Also copy `docker-compose.yml.dist` to `docker-compose.yml` and edit the
service names to include your username (this is so multiple people can work on
one workstation without image conflicts):

```
app_USERNAME:   ->  app_myusername:


dev_USERNAME:   ->  dev_myusername:
  extends:
    service: app_USERNAME   ->  service: app_myusername
  links:
    - redis_USERNAME:redis  ->  - redis_myusername:redis

redis_USERNAME: ->  redis_myusername:
```

Finally, run the `docker-compose` commands you need to actually start
developing.

If you would like to develop *in a development environment*, run the following
command:

```
$ docker-compose run --service-ports --rm dev_myusername bash   # puts you in a dev shell
```

If you would just like to run a development instance, run the following
command:

```
$ docker-compose up dev_myusername   # starts running the app on port 8000
```

If changes have been made to the dockerfiles (`dockerfiles/app` or the remote
`elijahcaine/centos-ruby`) run the following command to re-build your
containers:

```
$ docker-compose build  # builds all containers listed in docker-compose.yml
```

You may need to run the above commands if you have not given your user
permission to run `docker` commands.

IaM is developed using the most recent versions of `docker` and
`docker-compose` (as of mid 2016).
