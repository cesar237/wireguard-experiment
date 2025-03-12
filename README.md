# Wireguard Experiment
This project aims to evaluate the scalability of Wireguard VPN, taking into account multiple factors.

Requirements:
- OS: Debian 12
- Root rights

1. Initialize the testing environment. 
This will depend on the platform that is used.

If the nodes have been reserved on G5k, then:
- either pass the list of machines in file `EXPERIMENT_DATA/NODES`.
- or give the reservation ID to automatically fetch the list of reserved machines in file `EXPERIMENT_DATA/JOB_ID`

Note: You should have an odd number of machines in NODES

After listing the machines that will be used for the experiment, If you have N machines, the script will automatically chose 1 machine as the server, (N-1)/2 machines as clients and (N-1)/2 machines as targets. 

To automatically initialize the playbooks and the environment, run the command:

`scripts/initialize_test_env.sh`

To setup the global environment for Wireguard, go into `inventory/vars.yaml`. Here you can update:
- `username` to setup the username that will be used to connect to your machines. (root by default to have all rights)
- `iface` to setup the network interface on which wireguard interface will be configured
- `n_clients`: to configure the total number of clients that will be used in experiment. MAX=1024
- `batch`: The number of clients per client node

2. Install the dependencies and configure your test environment.
Run the command:

`scripts/run_playbook.sh setup-eval benchmark-vanilla`

This will install all the dependencies and send all necessary scripts and configurations for the tests.

You can write custom playbooks fur running evals in diretory `playbooks`
