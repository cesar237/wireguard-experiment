#! /usr/bin/bash

. scripts/global_vars.sh

# Set config
playbook=$1
config=$2

ROOT=~/wireguard-experiment

if [ -z "$config" ]; then
    config=default
fi


rm $data_dir/CURRENT_EXP
echo $config > $data_dir/CURRENT_EXP

if [ -z "$playbook" ]; then
    echo "Please, put a playbook!"
    echo "Usage: run_playbook.sh PLAYBOOK [CONFIG]"
    echo "Warning! default CONFIG=default"
    exit 1
fi

echo $config > $ROOT/EXPERIMENT_DATA/TEST_CONFIG
ansible-playbook -i inventory -i $ROOT/eval-configs/${config}.yaml $ROOT/playbooks/$playbook.yml -f 8
