Here is a professional and clear `README.md` file for your **wireguard-experiment** project:

---

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

Use any cloud or bare-metal provider to reserve the machines for the experiment. Ensure:

* SSH access is available
* You have `root` privileges

### 2. Update Inventory

Edit the file:

```
EXPERIMENT_DATA/NODES
```

...to include the IP addresses or hostnames of the machines.

### 3. Initialize Test Environment

Run the following script to generate Ansible inventories and initialize metadata:

```bash
scripts/initialize_testenv.sh
```

### 4. Launch the Evaluation

Use the provided wrapper script to run the entire setup and start the experiment:

```bash
scripts/run_setup_eval.sh
```

Alternatively, you can run the Ansible playbooks manually:

```bash
ansible-playbook -i inventory/hosts.yaml playbooks/setup-eval.yml
ansible-playbook -i inventory/hosts.yaml playbooks/start-eval.yml
```

> See the [Playbooks](#-ansible-playbooks) section for the full list of available playbooks.

### 5. Configure Test Cases

Edit one of the existing configs in `eval-configs/` or create your own. Example:

```
eval-configs/benchmark-wireguard-multi-queue.yaml
```

Each config defines a specific setup and performance evaluation strategy.

### 6. Retrieve Results

After the evaluation completes, collect results using:

```bash
scripts/retrieve-results.sh
```

Results will be stored in the `results/` directory.

---

## 📂 Ansible Playbooks

The key playbooks are:

* **setup-eval.yml** — Set up WireGuard, kernel modules, and other dependencies
* **start-eval.yml** — Launch the performance evaluation
* **stop-eval.yml** — Stop all services and clean up
* **reload-eval.yml** — Reload configuration or restart services
* **upload-config-files.yml** — Push experiment config files to remote nodes

---

## 🛠 Scripts Directory

A few useful scripts:

* `initialize_testenv.sh` — Prepares the experiment metadata and inventory
* `run_setup_eval.sh` — High-level runner for setup and start
* `retrieve-results.sh` — Pulls results back to the local machine
* `deploy_env.sh`, `run_configs.sh`, etc. — Additional helpers for automation

---

## 🧪 Creating Custom Benchmarks

You can define new experiment scenarios by creating new YAML files under `eval-configs/`. These YAML files drive the configuration logic, interface with the test scripts, and define the evaluation parameters (e.g., batch size, queuing behavior, etc.).

---

## 📊 Output & Results

All benchmark data is collected and saved under the `results/` directory, with subdirectories for each test configuration and run.

---

## 🧩 Requirements

* Bash 4+
* Python 3.6+
* Ansible 2.10+
* SSH access to all nodes with root permissions
* Optionally, patched Linux kernels or WireGuard modules (see `wireguard-artefacts/`)

## Important Note

* The current version only works fine with debian12 operating systems. To run the evaluation on other system, you need to update the names of the dependencies to install in playbooks/install-dependencies.yml

---
