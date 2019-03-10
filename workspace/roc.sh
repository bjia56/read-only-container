#!/bin/bash

# Are we running as root?
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

ROOTFS=$(pwd -P)/rootfs

# Create rootfs directory, if it does not exist
mkdir -p $ROOTFS

# Mount root
mount -R -r / $ROOTFS

# Run container
runc run roc

# Teardown mount
mount --make-rprivate $ROOTFS
umount -R $ROOTFS
