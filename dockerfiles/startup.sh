trap /data/code/dockerfiles/cleanup.sh EXIT
export REDIS_HOST=`getent hosts redis | awk '{ print $1 }'`
export POSTGRES_HOST=`getent hosts postgres | awk '{ print $1 }'`
