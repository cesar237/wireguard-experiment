#! /usr/bin/bash

# Use jq or yq to get necessary information with oarstat and the job's id
get_nodes() {
	JOB_ID=$1
	oarstat -j $JOB_ID -J | jq -r ".\"$JOB_ID\".assigned_network_address[]"
}

ka_machine_args() {
	JOB_ID=$1
	for node in $(get_nodes $JOB_ID | cut -d. -f1); do
		echo -n "-m $node ";
	done
}
