#!/bin/bash

CWD=$(/usr/bin/dirname "$0")
LOG_FILE=$1

if [ -z "$LOG_FILE" ]; then
    LOG_FILE=mem.$$.csv
fi

$(cd $CWD; go build -o profile)

sudo $CWD/profile tini > $LOG_FILE &
sudo renice -n -10 $! > /dev/null
sudo renice -n -10 $$ > /dev/null

$CWD/tini -s -- $CWD/../glassbox/start.sh sleep 5
