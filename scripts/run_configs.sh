#! /usr/bin/bash


ROOT=~/wireguard-experiment
. $ROOT/scripts/global_vars.sh

WAIT_TIME=$(( 150 * 2 * 3 ))
# wait_time = unit_duration_s * smt * nclients * runs

now="date +%H:%M:%S"

touch $data_dir/DONE_EXP
touch $data_dir/CURRENT_EXP

if  [ -z $1 ]; then
    echo "Please give at least one config. See config list in eval-congifs dir..."
    exit 1
else
    configs=$@
fi

for config in $configs; do
    echo $config > $data_dir/CURRENT_EXP

    cp $ROOT/eval-configs/$config.yaml $data_dir/

    # if [ -n "$(list_done_tests | grep -e ^$config$)" ]; then
    #     echo $config already evaluated. Skipping...
    # else

    echo "[$($now)] Starting Eval for configuration: $config..."
    $script_dir/run_playbook.sh start-eval $config
    sleep_progress $WAIT_TIME
    echo "[$($now)] Test Finished!"

    echo "[$($now)] Retrieving all results for $config..."
    $script_dir/retrieve-results.sh
    echo "[$($now)] Results retrieved!"

    echo "$config" >> $data_dir/DONE_EXP
    # fi
done
