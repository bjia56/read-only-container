#!/bin/bash

REAL_UID=$1
REAL_GID=$2
USR_PATH=$3
WORK_DIR=$4
ROOTFS=$WORK_DIR/rootfs
X11_DIR=$WORK_DIR/.X11-unix
OVERLAY_HOME=$WORK_DIR/overlay_home
OVERLAY_HOME_WORKDIR=$WORK_DIR/overlay_home_work
UUID=$5
USR_HOME=$(/usr/bin/getent passwd "$REAL_UID" | /usr/bin/cut -d: -f6)
CALLING_USR_NAME=$(logname)
CWD=$(/usr/bin/dirname "$0")
HOSTNAME=$(hostname)
CTR_ID=$6

# Create workspace with tmpfs
/bin/mount -t tmpfs -o size=4m,nr_inodes=1k,mode=777 tmpfs $WORK_DIR

# Create rootfs directory
/bin/mkdir -p $ROOTFS

# Create overlayfs workspace
# overlayfs on $HOME allows applications to manage dotfiles without error
/bin/mkdir -p $OVERLAY_HOME
/bin/mkdir -p $OVERLAY_HOME_WORKDIR

# Create X11 proxy
if [ -n "$DISPLAY" ]; then
    TMP=${DISPLAY#*:}
    DISPLAY_NUM=${TMP%.*}

    /bin/mkdir -p $X11_DIR
    /usr/bin/touch $OVERLAY_HOME/.Xauthority

    # Get the xauth info for the calling user
    XAUTH_INFO=$(HOME=$(/usr/bin/getent passwd "$CALLING_USR_NAME" | /usr/bin/cut -d: -f6); /usr/bin/xauth list $DISPLAY | cut -d ' ' -f 3,5)
    (HOME=$OVERLAY_HOME; /usr/bin/xauth add :$DISPLAY_NUM $XAUTH_INFO)

    /bin/chown -R $REAL_UID:$REAL_GID $X11_DIR

    /usr/bin/sudo -u \#$REAL_UID /usr/bin/socat unix-listen:$X11_DIR/X$DISPLAY_NUM,fork,unlink-early tcp-connect:localhost:$((6000 + $DISPLAY_NUM)) &
fi

/bin/chown -R $REAL_UID:$REAL_GID $OVERLAY_HOME
/bin/chown -R $REAL_UID:$REAL_GID $OVERLAY_HOME_WORKDIR

# Make config
$CWD/generate_config.sh $REAL_UID $REAL_GID "$USR_PATH" $WORK_DIR $ROOTFS $CTR_ID $DISPLAY_NUM > $WORK_DIR/config.json

# Mount root with bindfs
/usr/bin/bindfs -r / $ROOTFS

# Mask $HOME, /bin, /usr/sbin with overlayfs workspace
/bin/mount -t overlay overlay -o lowerdir=$ROOTFS$USR_HOME,upperdir=$OVERLAY_HOME,workdir=$OVERLAY_HOME_WORKDIR $ROOTFS$USR_HOME

# Run container
/usr/local/sbin/runc run -b $WORK_DIR $UUID

# Teardown overlay
/bin/umount $ROOTFS$USR_HOME

# Teardown bindfs
/bin/umount $ROOTFS

# Teardown X11 proxy
if [ -n "$DISPLAY" ]; then
    X11_PROXY_PIDS=$(ps -ef | grep socat | grep $UUID | awk '{print $2}' | tr -s '\n' ' ')
    if [ -n "$X11_PROXY_PIDS" ]; then
        kill $X11_PROXY_PIDS
    fi
fi

# Clean up tmpfs
WORK_DIR_BUSY=true
while $WORK_DIR_BUSY; do
    /bin/umount $WORK_DIR
    if [ $? -ne 0 ]; then
        sleep 1
    else
        WORK_DIR_BUSY=false
    fi
done
