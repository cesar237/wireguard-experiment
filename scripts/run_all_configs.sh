#! /usr/bin/bash


ROOT=~/wireguard-experiment
. $ROOT/scripts/global_vars.sh

WAIT_TIME=$(( 65 * 6 * 2 * 3 ))

now="date +%H:%M:%S"

for config in $config_list; do
    echo "[$($now)] Starting Eval for configuration: $config..."
    $script_dir/run_playbook.sh start-eval $config
    sleep_progress $WAIT_TIME
    echo "[$($now)] Test Finished!"

    echo "[$($now)] Retrieving all results for $config..."
    $script_dir/retrieve-results.sh
    echo "[$($now)] Results retrieved!"
done
