#! /usr/bin/bash

. scripts/global_vars.sh

scripts/deploy_env.sh

# scripts/reboot-all.sh
# eval=upload--yes-kernel-v1
# scripts/run_playbook.sh setup-eval ${eval} && \
# scripts/run_configs.sh ${eval}

# # scripts/reboot-all.sh
# eval=upload--partial-kernel-v1
# scripts/run_playbook.sh setup-eval ${eval} && \
# scripts/run_configs.sh ${eval}

# # scripts/reboot-all.sh
# eval=upload--yes-kernel-v3
# scripts/run_playbook.sh setup-eval ${eval} && \
# scripts/run_configs.sh ${eval}

# # scripts/reboot-all.sh
# eval=upload--partial-kernel-v3
# scripts/run_playbook.sh setup-eval ${eval} && \
# scripts/run_configs.sh ${eval}

# scripts/reboot-all.sh
eval=upload--yes-kernel-v3-bp
scripts/run_playbook.sh setup-eval ${eval} && \
scripts/run_configs.sh ${eval}

# scripts/reboot-all.sh
eval=upload--partial-kernel-v3-bp
scripts/run_playbook.sh setup-eval ${eval} && \
scripts/run_configs.sh ${eval}


scripts/reboot-all.sh
eval=upload--partial-kernel-v1-check-port
scripts/run_playbook.sh setup-eval ${eval} && \
scripts/run_configs.sh ${eval}
