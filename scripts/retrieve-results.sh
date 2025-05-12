#!/bin/bash


. ~/wireguard-experiment/scripts/global_vars.sh

# Create result directory with custom uid
res_dir="results-$(uuidgen | cut -d- -f1)"

mkdir -p results/
mkdir -p $res_dir
mkdir -p $res_dir/clients
mkdir -p $res_dir/server

# Retreive results from server
scp root@$server:/tmp/results.tar.zst $res_dir/server/results.tar.zst

# Zip and retreive results
ssh root@$server "cd /tmp; zip -r results.zip results"
scp root@$server:/tmp/results.zip $res_dir/server/results.zip

# Retreive results from clients
# echo $clients
for node in $clients; do
    name=`echo $node | cut -d. -f1`
    mkdir -p $res_dir/clients/$name
    ssh root@$name "cd /tmp; zip -r results.zip results"
    scp root@$name:/tmp/results.tar.zst $res_dir/clients/$name/results.tar.zst
    scp root@$name:/tmp/results.zip $res_dir/clients/$name/results.zip
done

# Copy Experiment metadata in result directory
cp -r EXPERIMENT_DATA $res_dir

mv $res_dir results/
