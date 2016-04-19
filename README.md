# Invoicing and Metrics


## Goal

Collect billable metrics from projects hosted at the OSL.


## Status

Design and research phase - 1-27-16

## Development (with Docker)

Invoicing and Metric (iam) is developed in `docker` using `docker-compose`:

- `docker` version 1.10.3
- `docker-compose` version 1.6.2.

### Setting up the Development Environment

After you have cloned the repository and installed the packages listed above
run the following:

First set the `COMPOSE_PROJECT_NAME` variable. This name-spaces your containers
so multiple users can develop independently on the same machine.

Set `.bashrc` with your shell's config file (`~/.zshrc` for instance).

**Note**: If you have not set the `docker` group settings correctly you will
need to add the above line to the `root` user's `.bashrc` or configure your
host machine appropriately (or do things in a Virtual Machine).

```
$ echo "export COMPOSE_PROJECT_NAME=$USER" >> ~/.bashrc
$ source ~/.bashrc
```

Also copy `dockerfiles/app.env.dist` to `dockerfiles/app.env`. There aren't any
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
$ docker-compose --service-ports run dev bash
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
├── cleanup.sh        # Changes file permissions from root to $USER on shell exit
└── startup.sh        # general statup needs (dynamic env vars, etc).
```

Some Environment variables are set:

```
$REDIS_HOST    # The host on which the linked redis container can be reached
$POSTGRES_PORT # The host on which the linked postgres container can be reached
```
