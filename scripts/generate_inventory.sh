#!/bin/bash


ROOT=~/wireguard-experiment

. $ROOT/scripts/global_vars.sh


function inventory_entry() {
	echo "    $1:"
}


cat << EOF
---
server:
  hosts:
EOF

inventory_entry $server

cat << EOF
targets:
  hosts:
EOF
for target in $targets; do
	inventory_entry $target
done

cat << EOF
clients:
  hosts:
EOF
for client in $clients; do
	inventory_entry $client
done

cat << EOF
wg:
  children:
    server:
    clients:
EOF
