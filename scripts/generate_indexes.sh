#!/bin/bash

ROOT=~/wireguard-experiment

. $ROOT/scripts/global_vars.sh

clients=`cat $CLIENTFILE`
total=`wc -l $CLIENTFILE | cut -d " " -f 1`

generate_client_index() {
	idx=0
	echo "{"
	for client in $clients; do
		idx=$(( idx + 1 ))
		echo -n "  \"$client\": $idx"
		if [[ $idx -eq $total ]]
		then
			echo 
		else
			echo ,
		fi
	done
	echo "}"
}

generate_target_index() {
	echo "{"
	for i in `seq 1 $total`; do
		client=`cat $CLIENTFILE | head -n $i | tail -n 1`
		target=`cat $TARGETFILE | head -n $i | tail -n 1`
		echo -n "  \"$client\": \"$target\""
		if [[ $i -eq $total ]]
		then
			echo 
		else
			echo ,
		fi
	done
	echo "}"
}

generate_client_index > $static_dir/index.json
generate_target_index > $static_dir/target_index.json
