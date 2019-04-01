#!/bin/bash
BRIDGE=$1
NEW_NS="runc$2"
CONTAINER_IF="eth1"
VETH_HOST="veth-host$2"
VETH_GUEST="veth-guest$2"

# remove iptables TEE rule
iptables -t mangle -D PREROUTING -i $PRIMARY -j TEE --gateway 192.168.10.10$3

# delete veth pair
ip link del $VETH_HOST
#ip netns exec $NEW_NS ip link del $VETH_GUEST

# delete namespace
ip netns del $NEW_NS

# delete bridge
# not sure when to do this if multiple containers, when no veth-hosts left
# ip link set $BRIDGE down
# brctl delbr $BRIDGE
