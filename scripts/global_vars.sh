#! /usr/bin/bash

export ROOT=~/wireguard-experiment

export data_dir=$ROOT/EXPERIMENT_DATA
export script_dir=$ROOT/scripts
export static_dir=$ROOT/static
export inventory_dir=$ROOT/inventory
export archive_dir=$ROOT/wireguard-artefacts
export config_dir=$ROOT/eval-configs

export CLIENTFILE=$data_dir/CLIENTS
export TARGETFILE=$data_dir/TARGETS
export SERVERFILE=$data_dir/SERVER
export NODEFILE=$data_dir/NODES

export JOB_ID=`cat $data_dir/JOB_ID`

export server=$(cat $SERVERFILE)
export targets=$(cat $TARGETFILE)
export clients=$(cat $CLIENTFILE)
export nodes=$(cat $NODEFILE)

export config_list=$(ls $config_dir | cut -d. -f1)


function sleep_progress() {
    bar_size=50
    bar_char="#"
    bar_todo="-"
    sleep_time=$1

    for current in `seq 1 $sleep_time`; do
        percent=$(( current * 50 / sleep_time ))
        todo=$((50 - percent))

        done_bar=$(printf "%${percent}s" | tr " " "$bar_char")
        todo_bar=$(printf "%${todo}s" | tr " " "$bar_todo")

        curr=$(printf "%4ds" $(( sleep_time - current )))

        echo -ne "\rProgress: [${done_bar}${todo_bar}] $curr"
        sleep 1
    done
    echo
}