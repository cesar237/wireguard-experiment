#! /usr/bin/bash


. ~/wireguard-experiment/scripts/global_vars.sh

# Create result directory with custom uid
res_dir="results-$(uuidgen | cut -d- -f1)"

mkdir -p results/
mkdir -p $res_dir
mkdir -p $res_dir/clients
mkdir -p $res_dir/server

# Retreive results from server
rsync -zvr root@$server:/tmp/results.tar.zst $res_dir/server/results.tar.zst

# Retreive results from clients
# echo $clients
for node in $clients; do
    name=`echo $node | cut -d. -f1`
    mkdir -p $res_dir/clients/$name
    rsync -zvr root@$name:/tmp/results.tar.zst $res_dir/clients/$name/results.tar.zst
done

# Copy Experiment metadata in result directory
cp -r EXPERIMENT_DATA $res_dir

mv $res_dir results/
