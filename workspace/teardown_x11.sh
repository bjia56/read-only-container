#!/bin/bash

UUID=$1

if [ -z "$DISPLAY" ]; then
    >&2 /bin/echo "no DISPLAY variable set, exiting"
    exit 1
fi

X11_PROXY_PIDS=$(/bin/ps -ef | /bin/grep socat | /bin/grep $UUID | /usr/bin/awk '{print $2}' | /usr/bin/tr -s '\n' ' ')
if [ -n "$X11_PROXY_PIDS" ]; then
    /bin/kill $X11_PROXY_PIDS
fi
