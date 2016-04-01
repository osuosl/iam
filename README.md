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

Finally, run the `docker-compose` commands you need to actually start
developing.

If you would like to develop *in a development environment*, run the following
command:

```
$ docker-compose run --service-ports --rm dev bash   # puts you in a dev shell
```

If you would just like to run a development instance, run the following
command:

```
$ docker-compose up dev   # starts running the app on port 8000
```

You may need to run the above commands if you have not given your user
permission to run `docker` commands.

IaM is developed using the most recent versions of `docker` and
`docker-compose` (as of mid 2016).
