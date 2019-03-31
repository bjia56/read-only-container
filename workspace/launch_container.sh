#!/bin/bash

REAL_UID=$1
REAL_GID=$2
USR_PATH=$3
WORK_DIR=$4
ROOTFS=$5
UUID=$6
CWD=$(/usr/bin/dirname "$0")
HOSTNAME=$(hostname)

# Create X11 proxy
if [ -n "$DISPLAY" ]; then
    TMP=${DISPLAY#*:}
    DISPLAY_NUM=${TMP%.*}

    mkdir -p $WORK_DIR/.X11-unix
    touch $WORK_DIR/.X11-unix/.Xauthority

    XAUTH_INFO=$(xauth list $DISPLAY | cut -d ' ' -f 3,5)
    echo $XAUTH_INFO
    (HOME=$WORK_DIR/.X11-unix; xauth add :$DISPLAY_NUM $XAUTH_INFO)
    (HOME=$WORK_DIR/.X11-unix; xauth list)

    chown -R $REAL_UID:$REAL_GID $WORK_DIR/.X11-unix

    sudo -u \#$REAL_UID socat unix-listen:$WORK_DIR/.X11-unix/X$DISPLAY_NUM,fork,unlink-early tcp-connect:localhost:$((6000 + $DISPLAY_NUM)) &
    X11_PROXY_PID=$!
fi

# Make config
$CWD/generate_config.sh $REAL_UID $REAL_GID "$USR_PATH" $WORK_DIR $ROOTFS $DISPLAY_NUM > $WORK_DIR/config.json

# Mount root
/usr/bin/bindfs -r / $ROOTFS

# Run container
/usr/local/sbin/runc run -b $WORK_DIR $UUID

# Teardown mount
umount $ROOTFS

# Teardown X11 proxy
if [ -n "$X11_PROXY_PID" ]; then
    kill "$X11_PROXY_PID"
fi
