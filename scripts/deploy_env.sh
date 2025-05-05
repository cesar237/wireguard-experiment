#! /usr/bin/bash

ROOT=~/wireguard-experiment
. $ROOT/scripts/global_vars.sh
. $ROOT/scripts/helpers.sh

update_job_id


OS=debian12-6.1.0
JOB_ID=$(cat $data_dir/JOB_ID)


# Get the list of nodes from JOB_ID reservation
get_nodes $JOB_ID > $data_dir/NODES

# Keep the OS environment information
kaenv3 debian12-nfs > $data_dir/OS_ENV.yaml

# Deploy the same env on all machines
kadeploy3 $OS $(ka_machine_args $JOB_ID)

# for node in $(get_nodes $JOB_ID); do
#     ssh root@$node "apt install -y linux-image-6.1.0-32-amd64"
# done

# kareboot3 simple $(ka_machine_args $JOB_ID)

# Initialize testenv
$script_dir/initialize_testenv.sh

