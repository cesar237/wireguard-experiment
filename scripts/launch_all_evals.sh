#! /usr/bin/bash

clients=`cat CLIENTS`
server=`cat SERVER`

module_basedir=~/ansible/wireguard_artefacts/wireguard_source_code
ansible_config_basedir=~/ansible/test_config

echo Launching all evaluations...

kareboot3 simple --force

# Base
echo Testing BASE...
./eval_wg.sh wireguard-base.zip $ansible_config_basedir/inventory-wq.yaml wg.playbook.yaml base
# Threaded
echo Testing Threaded...
./eval_wg.sh wireguard-base.zip $ansible_config_basedir/inventory-threaded.yaml wg.playbook.yaml threaded
# Threaded Pinned
echo Testing Threaded Pinned...
./eval_wg.sh wireguard-base.zip $ansible_config_basedir/inventory-threaded-pinned.yaml wg.playbook.yaml threaded-pinned
# WQ
echo Testing WQ...
./eval_wg.sh wireguard-wq.zip $ansible_config_basedir/inventory-wq.yaml wg.playbook.yaml wq
# WQ RR
echo Testing WQ RR...
./eval_wg.sh wireguard-wq-lb.zip $ansible_config_basedir/inventory-wq.yaml wg.playbook.yaml wq-rr
