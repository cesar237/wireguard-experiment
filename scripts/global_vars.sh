#! /usr/bin/bash

export ROOT=~/wireguard-experiment

export data_dir=$ROOT/EXPERIMENT_DATA
export script_dir=$ROOT/scripts
export static_dir=$ROOT/static
export inventory_dir=$ROOT/inventory
export archive_dir=$ROOT/wireguard-artefacts

export CLIENTFILE=$data_dir/CLIENTS
export TARGETFILE=$data_dir/TARGETS
export SERVERFILE=$data_dir/SERVER
export NODEFILE=$data_dir/NODES

export server=`cat $SERVERFILE`
export targets=`cat $TARGETFILE`
export clients=`cat $CLIENTFILE`
