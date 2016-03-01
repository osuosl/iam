#!/bin/bash

###
# Compiles a docker container for development of IAM.
###
# WARNING:
#   This script mounts the current working directory to /root in the container.
#   Don't do anything stupid like `rm -rf /` in the container.
###

IMAGE='iam/dev'

# Help is requested.
if [[ $@ == '-h' || $@ == '--help' ]];
then
    echo "dockersetup.sh: Develop IAM in docker"
    echo
    echo "USAGE:"
    echo "dockersetup.sh [-b|--build] [-h|--help]"
    echo
    echo "-h | --help   : Prints his help menu"
    echo "-b | --build  : Does a full docker build"

# A build is requested.
elif [[ $@ == '-b' || $@ == '--build' ]];
then
    echo "This might take a while."
    echo "Feel free to grab a cup of coffee."

    # We run centos in production
    docker pull centos:latest

    # Build the container and tag it IAM/dev
    if [[ -f "Dockerfile" ]];
    then
        docker build -t $IMAGE .
    else
        echo "Missing the Dockerfile"
        exit 1
    fi

# Running the container is requested.
else
    docker images | grep iam

    if [[ $? == 1 ]];
    then
        echo "Run 'dockersetup.sh -b' first"
    else
        # The `rm -rf ...` at the end is due to a weird permissions error when
        # building. Comment out the end of the line if you need your history.
        docker run -it -v $PWD:/root $IMAGE $SHELL && rm -rf .bash_history .viminfo
    fi
fi
