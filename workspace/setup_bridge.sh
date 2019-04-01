#!/bin/bash

BRIDGE=$1
CTR_ID=$2
NEW_NS="runc$CTR_ID"
CONTAINER_IF="eth1"
VETH_HOST="veth-host$CTR_ID"
VETH_GUEST="veth-guest$CTR_ID"
PRIMARY=`ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//"`
BRIDGE_ISUP=`ip link show | grep "$BRIDGE:.*state UP"`

if [[ -z "$BRIDGE_ISUP" ]]; then
	# Create new bridge
	brctl addbr $BRIDGE

	# associate w ip address
	ip link set $BRIDGE up
	ip addr add 192.168.10.1/24 dev $BRIDGE
fi

# create linux veth device pair
ip link add name $VETH_HOST type veth peer name $VETH_GUEST
ip link set $VETH_HOST up
brctl addif $BRIDGE $VETH_HOST

# create new network namespace and network interface for container
ip netns add $NEW_NS
ip link set $VETH_GUEST netns $NEW_NS
ip netns exec $NEW_NS ip link set $VETH_GUEST name $CONTAINER_IF
ip netns exec $NEW_NS ip addr add 192.168.10.$CTR_ID/24 dev $CONTAINER_IF
ip netns exec $NEW_NS ip link set $CONTAINER_IF up
ip netns exec $NEW_NS ip route add default via 192.168.10.1

# IPtables rule to duplicate packets to container
iptables -t mangle -A PREROUTING -i $PRIMARY -j TEE --gateway 192.168.10.$CTR_ID
