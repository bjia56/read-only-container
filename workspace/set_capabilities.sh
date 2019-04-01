#!/bin/bash

CAPS="cap_net_admin,cap_net_raw+ep"
TCPDUMP_CAP=`getcap /usr/sbin/tcpdump  | awk '{ print $3 }'`
PING_CAP=`getcap /bin/ping  | awk '{ print $3 }'`

chmod 755 /usr/sbin/tcpdump

if [[ $TCPDUMP_CAP != *$CAPS* ]]; then 
	setcap cap_net_raw,cap_net_admin=ep /usr/sbin/tcpdump
fi
if [[ $PING_CAP != *$CAPS* ]]; then 
	setcap cap_net_raw,cap_net_admin=ep /bin/ping
fi
