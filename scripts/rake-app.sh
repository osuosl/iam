#!/bin/bash
source /data/code/dockerfiles/startup.sh
# Remove these later
cat >> 'unicorn.pid'
cat >> 'unicorn.stderr.log'
cat >> 'unicorn.stdout.log'
cat >> 'scheduler.pid'
#
exec unicorn -l0.0.0.0:4567 -c unicorn.rb
rake run
