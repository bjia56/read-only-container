#!/bin/bash

# Get current user context before switching to root
USER=$(/usr/bin/whoami)
REAL_UID=$(/usr/bin/id -u $USER)
REAL_GID=$(/usr/bin/id -g $USER)
UUID=$(/bin/cat /proc/sys/kernel/random/uuid)
ROC_DIR=/tmp/roc
WORK_DIR=$ROC_DIR/$UUID
CWD=$(/usr/bin/dirname "$0")
BRIDGE="runc0"
# unique container id; 255 is max number of containers
# also determines guest ip in bridge network
CTR_ID=$((RANDOM % 255))

if [ -n "$1" ]; then
    if [ "$1" = "shutdown" ]; then
        /usr/bin/sudo $CWD/teardown_bridge.sh $BRIDGE - shutdown
    else
        >&2 echo "invalid option"
        exit 1
    fi
    exit 0
fi


# Create workspace
/usr/bin/sudo /bin/mkdir -p $WORK_DIR

# Set up bridge network and iptables
/usr/bin/sudo $CWD/setup_bridge.sh $BRIDGE $CTR_ID

# Run the container launcher under its own fs namespace
/usr/bin/sudo /usr/bin/unshare -fm $CWD/launch_container.sh $REAL_UID $REAL_GID "$PATH" $WORK_DIR $UUID $CTR_ID
wait

# Cleanup
/usr/bin/sudo $CWD/teardown_bridge.sh $BRIDGE $CTR_ID
/usr/bin/sudo /bin/rm -r $WORK_DIR
