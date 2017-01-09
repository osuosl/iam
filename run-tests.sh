#!/bin/bash

rake migrate
status1=$?

rake spec
status2=$?

rake rubocop
status3=$?

if test $status1 -eq 0 && test $status2 -eq 0 && test $status3 -eq 0
then
	exit 0
else
	exit 1
fi
