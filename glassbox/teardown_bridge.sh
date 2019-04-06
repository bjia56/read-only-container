#!/bin/bash
BRIDGE=$1
NEW_NS="runc$2"
CONTAINER_IF="eth1"
VETH_HOST="veth-host$2"
VETH_GUEST="veth-guest$2"

if [ "$3" = "shutdown" ]; then
    /bin/echo "shutting down bridge"

    # delete bridge
    /sbin/iptables -D INPUT -i $BRIDGE -j DROP
    /bin/ip link set $BRIDGE down
    /sbin/brctl delbr $BRIDGE
    exit 0
fi

# remove iptables TEE rules
/sbin/iptables -t mangle -D POSTROUTING -j TEE --gateway 192.168.10.$2
/sbin/iptables -t mangle -D PREROUTING -j TEE --gateway 192.168.10.$2

# delete veth pair
/bin/ip link del $VETH_HOST

# delete namespace
/bin/ip netns del $NEW_NS
