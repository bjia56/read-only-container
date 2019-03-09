#!/bin/bash
# Note: this script should be run with sudo

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
