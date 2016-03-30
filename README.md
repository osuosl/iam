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
ENV USER     you_user_name
ENV PASSWORD you_container_password
ENV UID      your_local_uid
```

Finally, run the `docker-compose` commands you need to actually start
developing.

```
$ docker-compose up dev   # starts running the app on port 8000
# ~~~~or~~~~
$ docker-compose run --service-ports dev bash   # puts you in a dev shell
```

IaM is developed using the most recent versions of `docker` and
`docker-compose` (as of mid 2016).
