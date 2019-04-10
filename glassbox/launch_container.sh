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
CWD=$(/usr/bin/dirname "$0")
HOSTNAME=$(/bin/hostname)
CTR_ID=$6
CONTAINER_CMD=$7

# Create workspace with tmpfs
/bin/mount -t tmpfs -o size=4m,nr_inodes=1k,mode=777 tmpfs $WORK_DIR

# Create rootfs directory
/bin/mkdir -p $ROOTFS

# Create overlayfs workspace
# overlayfs on $HOME allows applications to manage dotfiles without error
/bin/mkdir -p $OVERLAY_HOME
/bin/mkdir -p $OVERLAY_HOME_WORKDIR

# Create X11 directory in case it is needed
/bin/mkdir -p $X11_DIR

# Create X11 proxy
if [ -n "$DISPLAY" ]; then
    $CWD/setup_x11.sh $REAL_UID $REAL_GID $X11_DIR $OVERLAY_HOME
fi

/bin/chown -R $REAL_UID:$REAL_GID $OVERLAY_HOME
/bin/chown -R $REAL_UID:$REAL_GID $OVERLAY_HOME_WORKDIR

# Make config
$CWD/generate_config.sh $REAL_UID $REAL_GID "$USR_PATH" $WORK_DIR $ROOTFS $CTR_ID "$CONTAINER_CMD" > $WORK_DIR/config.json

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
    $CWD/teardown_x11.sh $UUID
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
