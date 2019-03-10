#!/bin/bash

# Are we running as root?
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

ROOTFS=/tmp/roc_rootfs
UUID=$(cat /proc/sys/kernel/random/uuid)
BUNDLE=$(dirname "$0")

# Create rootfs directory, if it does not exist
mkdir -p $ROOTFS

read -d '' start_container <<SHELL
    # Mount root
    bindfs -r / $ROOTFS

    # Run container
    runc run -b $BUNDLE $UUID

    # Teardown mount
    umount $ROOTFS
SHELL

unshare -fm /bin/bash -c "$start_container"
wait
