trap /data/code/dockerfiles/cleanup.sh EXIT
export POSTGRES_HOST=`getent hosts postgres | awk '{ print $1 }'`
