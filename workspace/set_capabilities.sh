#!/bin/bash

ROOTFS=$1
CAPS="cap_net_admin,cap_net_raw+ep"
TCPDUMP_CAP=`getcap $ROOTFS/usr/sbin/tcpdump  | awk '{ print $3 }'`
PING_CAP=`getcap $ROOTFS/bin/ping  | awk '{ print $3 }'`

chmod 755 $ROOTFS/usr/sbin/tcpdump

if [[ $TCPDUMP_CAP != *$CAPS* ]]; then
	setcap cap_net_raw,cap_net_admin=ep $ROOTFS/usr/sbin/tcpdump
fi
if [[ $PING_CAP != *$CAPS* ]]; then
	setcap cap_net_raw,cap_net_admin=ep $ROOTFS/bin/ping
fi
