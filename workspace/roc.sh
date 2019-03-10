#!/bin/bash

# Are we running as root?
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

ROOTFS=$(pwd -P)/rootfs
UUID=$(cat /proc/sys/kernel/random/uuid)

# Create rootfs directory, if it does not exist
mkdir -p $ROOTFS

# Mount root
bindfs -r / $ROOTFS

# Run container
runc run $UUID

# Teardown mount
umount $ROOTFS
