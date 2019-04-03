#!/bin/bash
BRIDGE=$1
NEW_NS="runc$2"
CONTAINER_IF="eth1"
VETH_HOST="veth-host$2"
VETH_GUEST="veth-guest$2"

# remove iptables TEE rule
iptables -t mangle -D PREROUTING -j TEE --gateway 192.168.10.$2

# delete veth pair
ip link del $VETH_HOST

# delete namespace
ip netns del $NEW_NS

# delete bridge
# not sure when to do this if multiple containers, when no veth-hosts left
# iptables -D INPUT -i $BRIDGE -j DROP
# ip link set $BRIDGE down
# brctl delbr $BRIDGE
