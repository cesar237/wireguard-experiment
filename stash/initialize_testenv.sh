#! /bin/bash
# set -x

# This script here is for initializing the testenv
# $1 here is the number of nodes to consider. It must be <= to the number of available
# nodes and odd, so that we have 1 SERVER node and (n-1)//2 TARGETS and CLIENTS nodes

# First, generate SERVER, TARGETS and CLIENTS as partitions of available nodes
## 1. Get the number of nodes
number_of_nodes=`uniq $OAR_NODEFILE | wc -l`
if [[ -z $1 ]]
then
    number_of_nodes=`uniq $OAR_NODEFILE | wc -l`
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
    ./generate_files.sh $n
    ./generate_index.sh > index.json
    ./generate_target_index.sh > target_index.json
    ./generate_inventory.sh > inventory.yaml
fi

export PATH=$PATH:/home/hmounah/.local/bin
