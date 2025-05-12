#!/bin/bash

. scripts/global_vars.sh


distribute_ssh_key

# eval=benchmark-ipvs
# rm $data_dir/CURRENT_EXP
# echo $eval > $data_dir/CURRENT_EXP
# scripts/run_playbook.sh setup-eval ${eval}
# scripts/run_playbook.sh start-ipvs-eval ${eval}
# scripts/retrieve-results.sh
# benchmark-wireguard-steering 

# benchmarks="benchmark-wireguard-vanilla benchmark-wireguard-batch   benchmark-wireguard-multi-queue-pool benchmark-wireguard-multi-queue-pool-steering benchmark-wireguard-no-queue"

benchmarks="benchmark-wireguard-multi-queue-pool benchmark-wireguard-multi-queue-pool-steering benchmark-wireguard-no-queue"

# benchmark-vanilla benchmark-vanilla-no-ring benchmark-cryptonce-no-ring
# benchmarks="benchmark-vanilla"

for benchmark in $benchmarks; do
    # ./scripts/deploy_env.sh
    eval=$benchmark
    rm $data_dir/CURRENT_EXP
    echo $eval > $data_dir/CURRENT_EXP
    scripts/run_playbook.sh setup-eval ${eval}
    scripts/run_playbook.sh start-wg-eval ${eval}
    scripts/retrieve-results.sh
done

# eval=benchmark-vanilla
# rm $data_dir/CURRENT_EXP
# echo $eval > $data_dir/CURRENT_EXP
# scripts/run_playbook.sh setup-eval ${eval}
# scripts/run_playbook.sh start-wg-eval ${eval}
# scripts/retrieve-results.sh

# ./scripts/deploy_env.sh
# eval=benchmark-wireguard-multi-queue
# echo $eval > $data_dir/CURRENT_EXP
# scripts/run_playbook.sh setup-eval ${eval}
# scripts/run_playbook.sh start-wg-eval ${eval}
# scripts/retrieve-results.sh

# ./scripts/deploy_env.sh
# eval=benchmark-wireguard-batch-multi-queue
# echo $eval > $data_dir/CURRENT_EXP
# scripts/run_playbook.sh setup-eval ${eval}
# scripts/run_playbook.sh start-wg-eval ${eval}
# scripts/retrieve-results.sh

# ./scripts/deploy_env.sh
# eval=benchmark-wireguard-no-queue
# echo $eval > $data_dir/CURRENT_EXP
# scripts/run_playbook.sh setup-eval ${eval}
# scripts/run_playbook.sh start-wg-eval ${eval}
# scripts/retrieve-results.sh

# eval=benchmark-wireguard-multi
# echo $eval > $data_dir/CURRENT_EXP
# scripts/run_playbook.sh setup-eval ${eval}
# scripts/run_playbook.sh start-wg-batch-eval ${eval}
# scripts/retrieve-results.sh

