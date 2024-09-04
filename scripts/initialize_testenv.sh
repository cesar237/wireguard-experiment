#! /bin/bash
# set -x

ROOT=~/wireguard-experiment

. $ROOT/scripts/global_vars.sh

# This script here is for initializing the testenv
# $1 here is the number of nodes to consider. It must be <= to the number of available
# nodes and odd, so that we have 1 SERVER node and (n-1)//2 TARGETS and CLIENTS nodes

# First, generate SERVER, TARGETS and CLIENTS as partitions of available nodes
## 1. Get the number of nodes
number_of_nodes=`cat $data_dir/NODES | wc -l`
if [[ -z $1 ]]
then
    number_of_nodes=`cat $data_dir/NODES | wc -l`
else
    number_of_nodes=$1
fi

if (( number_of_nodes %2 == 0))
then
    echo "The specified number of nodes is even. It must be <= to the number of available"
    echo "nodes and odd, so that we have 1 SERVER node and (n-1)//2 TARGETS and CLIENTS nodes"
    echo "Consider specifying am odd number"
    exit 1;
else
    n=$(( number_of_nodes/2 ))
    $script_dir/generate_files.sh $n
    $script_dir/generate_indexes.sh
    $script_dir/generate_inventory.sh > $inventory_dir/hosts.yaml
fi

export PATH=$PATH:/home/hmounah/.local/bin

. $ROOT/.bashrc