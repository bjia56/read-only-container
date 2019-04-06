#!/bin/bash

BRIDGE=$1
CTR_ID=$2
NEW_NS="runc$CTR_ID"
CONTAINER_IF="eth1"
VETH_HOST="veth-host$CTR_ID"
VETH_GUEST="veth-guest$CTR_ID"
BRIDGE_ISUP=`/bin/ip link show | /bin/grep "$BRIDGE:.*"`

if [[ -z "$BRIDGE_ISUP" ]]; then
    # Create new bridge
    /sbin/brctl addbr $BRIDGE

    # associate w ip address
    /bin/ip link set $BRIDGE up
    /bin/ip addr add 192.168.10.1/24 dev $BRIDGE

    # iptables rule to drop packets from container
    /sbin/iptables -A INPUT -i $BRIDGE -j DROP
fi

# create linux veth device pair
/bin/ip link add name $VETH_HOST type veth peer name $VETH_GUEST
/bin/ip link set $VETH_HOST up
/sbin/brctl addif $BRIDGE $VETH_HOST

# create new network namespace and network interface for container
/bin/ip netns add $NEW_NS
/bin/ip link set $VETH_GUEST netns $NEW_NS
/bin/ip netns exec $NEW_NS /bin/ip link set $VETH_GUEST name $CONTAINER_IF
/bin/ip netns exec $NEW_NS /bin/ip addr add 192.168.10.$CTR_ID/24 dev $CONTAINER_IF
/bin/ip netns exec $NEW_NS /bin/ip link set $CONTAINER_IF up

# iptables rule to duplicate incoming packets to container
/sbin/iptables -t mangle -A PREROUTING -j TEE --gateway 192.168.10.$CTR_ID

# iptables rule to duplicate outgoing packets to container
/sbin/iptables -t mangle -A POSTROUTING -j TEE --gateway 192.168.10.$CTR_ID
