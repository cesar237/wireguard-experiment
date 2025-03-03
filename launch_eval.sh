#! /usr/bin/bash

. scripts/global_vars.sh

# scripts/deploy_env.sh
distribute_ssh_key


eval=benchmark-vanilla
echo $eval > $data_dir/CURRENT_EXP
scripts/run_playbook.sh setup-eval ${eval}
scripts/run_playbook.sh start-client-eval ${eval}
scripts/retrieve-results.sh

eval=benchmark-cryptonce
rm $data_dir/CURRENT_EXP
echo $eval > $data_dir/CURRENT_EXP
scripts/run_playbook.sh setup-eval ${eval}
scripts/run_playbook.sh start-client-eval ${eval}
scripts/retrieve-results.sh
