#! /usr/bin/bash

OS=debian12-nfs
data_dir=../EXPERIMENT_DATA
JOB_ID=$(cat $data_dir/JOB_ID)

. helpers.sh

# Get the list of nodes from JOB_ID reservation
get_nodes $JOB_ID > $data_dir/NODES

# Keep the OS environment information
kaenv3 debian12-nfs > $data_dir/OS_ENV.yaml

# Deploy the same env on all machines
kadeploy3 $OS $(ka_machine_args $JOB_ID)

