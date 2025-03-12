#! /usr/bin/bash

. scripts/global_vars.sh
distribute_ssh_key

./scripts/deploy_env.sh

eval=benchmark-vanilla
echo $eval > $data_dir/CURRENT_EXP
scripts/run_playbook.sh setup-eval ${eval}
scripts/run_playbook.sh start-wg-eval ${eval}
scripts/retrieve-results.sh

eval=benchmark-wireguard-batch
echo $eval > $data_dir/CURRENT_EXP
scripts/run_playbook.sh setup-eval ${eval}
scripts/run_playbook.sh start-wg-batch-eval ${eval}
scripts/retrieve-results.sh

# eval=benchmark-wireguard-multi
# echo $eval > $data_dir/CURRENT_EXP
# scripts/run_playbook.sh setup-eval ${eval}
# scripts/run_playbook.sh start-wg-batch-eval ${eval}
# scripts/retrieve-results.sh

