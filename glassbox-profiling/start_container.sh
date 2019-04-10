#!/bin/bash

CWD=$(/usr/bin/dirname "$0")
LOG_FILE=$1

if [ -z "$LOG_FILE" ]; then
    LOG_FILE=mem.$$.log
fi

sudo $CWD/profile.sh tini > $LOG_FILE &
$CWD/tini -s -- $CWD/../glassbox/start.sh sleep 15
