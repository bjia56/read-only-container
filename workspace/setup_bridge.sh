#!/bin/bash

RUNC="runc0"
PRIMARY=`ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//"`

# Create new bridge
brctl addbr $RUNC
ip link set $RUNC up
ip addr add 192.168.10.1/24 dev runc0
ip link add name veth-host type veth peer name veth-guest
ip link set veth-host up
brctl addif runc0 veth-host
ip netns add runc
ip link set veth-guest netns runc
ip netns exec runc ip link set veth-guest name eth1
ip netns exec runc ip addr add 192.168.10.101/24 dev eth1
ip netns exec runc ip link set eth1 up
ip netns exec runc ip route add default via 192.168.10.1

# IPtables rule to duplicate packets to container
iptables -t mangle -A PREROUTING -i $PRIMARY -j TEE --gateway 192.168.10.101
