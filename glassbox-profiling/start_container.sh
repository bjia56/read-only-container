#!/bin/bash

CWD=$(/usr/bin/dirname "$0")

sudo $CWD/profile.sh tini > mem.log &
$CWD/tini -s -- $CWD/../glassbox/start.sh sleep 15
