# wireguard-experiment

**wireguard-experiment** is a framework for evaluating the performance of [WireGuard](https://www.wireguard.com/) at scale across distributed systems. It provides a collection of Bash scripts and Ansible playbooks to automate the setup, execution, and teardown of performance experiments across a fleet of machines.

---

## 📦 Project Structure

```
├── eval-configs/           # YAML configs for various benchmark scenarios
├── EXPERIMENT_DATA/        # Metadata and state related to the current experiment
├── playbooks/              # Ansible playbooks for setting up and running experiments
├── scripts/                # Shell scripts for deploying and running evaluations
├── results/                # Stores experiment output and benchmark results
├── wireguard-artefacts/    # Kernel and WireGuard binaries/artifacts
├── templates/, static/, stash/, poc/  # Supporting files and utilities
```

---

## 🚀 Quick Start

### 1. Reserve Machines

If using grid5000, reserve machines with:

```bash
oarsub -t deploy -p <cluster> -l hosts=<nb_hosts>
```

Notes:
- Reserve an odd number of machines
- Reserve machines in deploy mode

For other cloud or bare-metal providers, ensure:
* SSH access is available
* You have `root` privileges

### 2. Set Up Environment Variables

Source the global variables script:

```bash
. scripts/global_vars.sh
```

### 3. Update Job ID

```bash
update_job_id
```

### 4. Deploy Debian 12 Environment

```bash
./scripts/deploy_env.sh
```

### 5. Update Environment Variables Again

```bash
. scripts/global_vars.sh
```

### 6. Update Inventory

The file `EXPERIMENT_DATA/NODES` should be automatically populated with the IP addresses or hostnames of the machines. Verify this file contains the correct information.

### 7. Initialize Test Environment

Run the following script to generate Ansible inventories and initialize metadata:

```bash
scripts/initialize_testenv.sh
```

### 8. Launch the Evaluation

Run the setup playbook with default configuration:

```bash
./scripts/run_playbook.sh setup-eval
```

Then run the WireGuard evaluation:

```bash
./scripts/run_playbook.sh start-wg-eval
```

Alternatively, you can specify a custom configuration:

```bash
./scripts/run_playbook.sh setup-eval <your_config>
```

For manual execution, use:

```bash
ansible-playbook -i inventory/hosts.yaml playbooks/setup-eval.yml
ansible-playbook -i inventory/hosts.yaml playbooks/start-eval.yml
```

> See the [Playbooks](#-ansible-playbooks) section for the full list of available playbooks.

### 9. Configure Test Cases

Edit one of the existing configs in `eval-configs/` or create your own. Example:

```
eval-configs/benchmark-wireguard-multi-queue.yaml
```

The default configuration is in:

```
eval-configs/default.yaml
```

Each config defines a specific setup and performance evaluation strategy.

### 10. Retrieve Results

After the evaluation completes, collect results using:

```bash
./scripts/retrieve_results.sh
```

Results will be stored in the `results/` directory as `result-XXXXX.zip`, where XXXXX is a unique ID for the experiment.

---

## 📂 Ansible Playbooks

The key playbooks are:

* **setup-eval.yml** — Set up WireGuard, kernel modules, and other dependencies
* **start-eval.yml** — Launch the performance evaluation
* **start-wg-eval.yaml** — Launch the WireGuard-specific evaluation
* **stop-eval.yml** — Stop all services and clean up
* **reload-eval.yml** — Reload configuration or restart services
* **upload-config-files.yml** — Push experiment config files to remote nodes
* **install-dependencies.yml** — Install required dependencies on remote nodes

---

## 🛠 Scripts Directory

A few useful scripts:

* `global_vars.sh` — Sets up global environment variables
* `initialize_testenv.sh` — Prepares the experiment metadata and inventory
* `run_setup_eval.sh` — High-level runner for setup and start
* `retrieve_results.sh` — Pulls results back to the local machine
* `deploy_env.sh` — Deploys the Debian 12 environment
* `run_playbook.sh` — Helper to run Ansible playbooks with configurations
* `run_configs.sh`, etc. — Additional helpers for automation

---

## 🧪 Creating Custom Benchmarks

You can define new experiment scenarios by creating new YAML files under `eval-configs/`. These YAML files drive the configuration logic, interface with the test scripts, and define the evaluation parameters (e.g., batch size, queuing behavior, etc.).

For detailed information about all available configuration parameters and their meanings, refer to the documentation file:

```
documentation/expe-config-format.md
```

This document provides a comprehensive explanation of each parameter in the configuration YAML files, including network settings, testing tool options, WireGuard implementation choices, and system tuning parameters.

---

## Output & Results

All benchmark data is collected and saved under the `results/` directory, with subdirectories for each test configuration and run. The results are packaged as `result-XXXXX.zip` files, where XXXXX is a unique ID for the experiment.

### Analyzing Results

To analyze the results, use the repository at [https://github.com/cesar237/wireguard-result-analysis.git](https://github.com/cesar237/wireguard-result-analysis.git). This repository contains a Jupyter notebook that will help you analyze the results.

---

## 🧩 Requirements

* Bash 4+
* Python 3.6+
* Ansible 2.10+
* SSH access to all nodes with root permissions
* Grid5000 account (if using Grid5000 for machine reservation)
* Optionally, patched Linux kernels or WireGuard modules (see `wireguard-artefacts/`)

## ⚠️ Important Notes

* The current version only works properly with Debian 12 operating systems. To run the evaluation on other systems, you need to update the names of the dependencies to install in `playbooks/install-dependencies.yml`.
* Always reserve an odd number of machines for optimal results.
* The deployment process is currently optimized for Grid5000 infrastructure but can be adapted to other environments.