#!/bin/bash

REAL_UID=$1
REAL_GID=$2
USR_PATH=$3
WORK_DIR=$4
ROOTFS=$5
UUID=$6
CWD=$(/usr/bin/dirname "$0")

# Make config
$CWD/generate_config.sh $REAL_UID $REAL_GID "$USR_PATH" $ROOTFS > $WORK_DIR/config.json

# Mount root
/usr/bin/bindfs -r / $ROOTFS

# Run container
/usr/local/sbin/runc run -b $WORK_DIR $UUID

# Teardown mount
umount $ROOTFS
