#!/bin/bash

# Get current user context before switching to root
USER=$(/usr/bin/whoami)
REAL_UID=$(/usr/bin/id -u $USER)
REAL_GID=$(/usr/bin/id -g $USER)
UUID=$(/bin/cat /proc/sys/kernel/random/uuid)
ROC_DIR=/tmp/roc
WORK_DIR=$ROC_DIR/$UUID
CWD=$(/usr/bin/dirname "$0")

# Create workspace
/usr/bin/sudo /bin/mkdir -p $WORK_DIR

# Set up bridge network between host/guest
/usr/bin/sudo $CWD/setup_bridge.sh

# Run the container launcher under its own fs namespace
/usr/bin/sudo /usr/bin/unshare -fm $CWD/launch_container.sh $REAL_UID $REAL_GID "$PATH" $WORK_DIR $UUID
wait

# Cleanup
/usr/bin/sudo /bin/rm -r $WORK_DIR
