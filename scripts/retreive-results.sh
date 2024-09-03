#! /usr/bin/bash


. ~/wireguard-experiment/scripts/global_vars.sh

# Create result directory with custom uid
res_dir="results-$(( uuidgen ))"

mkdir -p $res_dir
mkdir -p $res_dir/clients
mkdir -p $res_dir/server

# Retreive results from server
rsync -zvr root@$server:/tmp/results.tar.zst $res_dir/server/

# Retreive results from clients
for node in $clients; do   
    rsync -zvr root@$node:/tmp/results.tar.zst $res_dir/clients/$node &
done

mv res_dir results/
