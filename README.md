# Wireguard Experiment
This project aims to evaluate the scalability of Wireguard VPN, taking into account multiple factors.

1. Initialize the testing environment. 
This will depend on the machine that have been reserved.
If the nodes have been reserved on G5k, then either pass the list of machines, or give the reservation ID to automatically fetch the list of reserved machines.

Distributed network evaluation framework
- Define which type of experiment to run
- Setup the machines that will be used to run the experiment
- Log all steps
- Initialize the testing environment 
    - On the nodes
    - On the controller (local machine from which the experiment is run)
- The workflow: 1. Setup the experiment data on controler, 2. Setup the eval machines, 3. PreTest script, 4. Testing Script, 5. PostTest script, 6 Network configuration, 7 deployment over either kubernetes, docker swarm, vms, or baremetal
