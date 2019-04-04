#!/bin/bash

REAL_UID=$1
REAL_GID=$2
X11_DIR=$3
OVERLAY_HOME=$4

if [ -z "$DISPLAY" ]; then
    >&2 /bin/echo "no DISPLAY variable set, exiting"
    exit 1
fi

CALLING_USR_NAME=$(/usr/bin/logname)
CALLING_USR_HOME=$(/usr/bin/getent passwd "$CALLING_USR_NAME" | /usr/bin/cut -d: -f6)

# Calculate display number and location
DISPLAY_HOST=${DISPLAY%:*}
DISPLAY_NUM_AND_WINDOW=${DISPLAY#*:}
DISPLAY_NUM=${DISPLAY_NUM_AND_WINDOW%.*}

if [ -z "$DISPLAY_HOST" ]; then
    USE_UNIX_DISPLAY=1
fi

/usr/bin/touch $OVERLAY_HOME/.Xauthority

# Get the xauth info for the calling user
# This is to reliably transfer correct xauth info from the
# current user session into the container
XAUTH_INFO=$(HOME=$CALLING_USR_HOME; /usr/bin/xauth list $DISPLAY | /usr/bin/cut -d ' ' -f 3,5)
(HOME=$OVERLAY_HOME; /usr/bin/xauth add :$DISPLAY_NUM $XAUTH_INFO)

/bin/chown -R $REAL_UID:$REAL_GID $X11_DIR

if [ -n "$USE_UNIX_DISPLAY" ]; then
    /usr/bin/sudo -u \#$REAL_UID /usr/bin/socat unix-listen:$X11_DIR/X$DISPLAY_NUM,fork,unlink-early unix-connect:/tmp/.X11-unix/X$DISPLAY_NUM &
else
    /usr/bin/sudo -u \#$REAL_UID /usr/bin/socat unix-listen:$X11_DIR/X$DISPLAY_NUM,fork,unlink-early tcp-connect:$DISPLAY_HOST:$((6000 + $DISPLAY_NUM)) &
fi
