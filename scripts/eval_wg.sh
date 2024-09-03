#! /usr/bin/bash

. ~/.bashrc
server=`cat ~/ansible/SERVER`
echo SERVER=$server

wg_module_path_prefix=wireguard_artefacts/wireguard_source_code
wg_module_path=$1
ansible_config=$2
playbook=$3
output_dir=$4

WAIT_TIME=1200
mkdir -p ansible/results

send_and_install_wireguard() {
    scp $wg_module_path_prefix/$wg_module_path root@$server:/tmp
    ssh root@$server "cd /tmp; rm -rv wireguard; unzip $wg_module_path; cp -vr wireguard /usr/src/linux-6.1.90/drivers/net/"
    ssh root@$server "cd /usr/src/linux-6.1.90; make -j 36; make modules_install -j 36"
}

# #1. remove current wireguard module
# echo "Removal of currently loaded wireguard module"
# ssh root@$server "wg-quick down ~/confs/wg.conf"

#2. Send and install wireguard
send_and_install_wireguard

#4. Launch test
# kareboot3 simple -m $server &&
ssh root@$server "rmmod wireguard && modprobe wireguard";
ansible-playbook -i $ansible_config $playbook -f 8

#5. Wait until test is finished
sleep $WAIT_TIME

#6. Retrieve results to $output_dir
mkdir -p ~/ansible/results/$output_dir/server
scp -r root@$server:/tmp/results ~/ansible/results/$output_dir/server
for client in `cat CLIENTS`; do
    mkdir -p ~/ansible/results/$output_dir/clients/$client
    scp -r root@$client:/tmp/results ~/ansible/results/$output_dir/clients/$client &
done
