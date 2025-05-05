#!/bin/bash

sysctl net.ipv4.ip_forward=1
echo off > /sys/devices/system/cpu/smt/control
for i in `seq 1 18`; do
    echo 0 > /sys/devices/system/cpu/cpu$i/online
done

n=100
for i in `seq 1 $n`; do
    sockperf tp --mps=12500 --tcp -i gros-97 -p $(( 24000 + i)) -t 10 -m 1400 --client_ip 192.168.1.$((i+1)) > sp_$i.log &
done


n=100
for i in `seq 1 $n`; do
    sockperf ul --mps=12500 --tcp -i gros-97 -p $(( 24000 + i)) -t 10 -m 1400 --client_ip 192.168.1.$((i+1)) > sock_$i.log &
done

function run_throughput_eval(){
    target=$1
    n=$2
    mps=$3
    # port=$4
    for i in `seq 1 $n`; do
        sockperf tp --mps=$mps --tcp -i $target -t 10 -p $(( 24000 + i)) -m 1400 > sp_$i.log &
    done
}

function run_latency_eval(){
    target=$1
    n=$2
    mps=$3
    # port=$4
    for i in `seq 1 $n`; do
        sockperf ul --mps=$mps --tcp -i $target -p $(( 24000 + i)) -t 10 -m 1400 > lat_$i.log &
    done   
}

# function run_latency_eval(){
#     n=$1
#     for i in `seq 1 $n`; do
#         sockperf ul --mps=$2 --tcp -i gros-97 -p $(( 24000 + i)) -t 10 -m 1400 --client_ip 192.168.1.$((i+1)) > sock_$i.log &
#     done
# }

function median() {
	sort -n | awk '
		BEGIN {c=0}
		{nums[c++]=$1}
		END {
			if (c%2==0) print (nums[int(c/2)-1]+nums[int(c/2)])/2;
			else print nums[int(c/2)]
		}
	'
}

function sum() {
    paste -sd+ | bc
}

function compute_metrics(){
    path=$1
    pushd $path > /dev/null
    echo -n Bandwidth=
    grep "BandWidth" *.log | tr -d '('  | awk '{ print $(NF-1) }' | sum 
    echo -n Tail Latency=
    grep "99.000" *.log | awk '{ print $NF }' | median
    popd > /dev/null
}

function launch_pidstat(){
    pidstat 1 > pidstat.log &
    sar -A -o sar.data 1 > /dev/null &
    sleep $1
    killall pidstat
    killall sar
}


172.16.66.86, 0xac104256

SERVER_IP: 1396838572
IP: 172.16.66.8
As 32-bit integer (network byte order): 2886746632
Hex representation: 0xac104208

TARGET_IP: 1447170220
IP: 172.16.66.83
As 32-bit integer (network byte order): 2886746707
Hex representation: 0xac104253

sudo apt install -y tree psmisc automake dwarves net-tools iproute2 curl bc ethtool git zip traceroute iftop htop tcpdump libtool-bin ipvsadm sockperf dstat tcpdump dtach sysstat byobu





function run_throughput_eval(){
    target=$1
    n=$2
    mps=$3
    # port=$4
    for i in `seq 1 $n`; do
        sockperf tp --mps=$mps --tcp -i $target -t 10 -p $(( 24000 + i)) -m 1400 > sp_$i.log &
    done
}

function run_latency_eval(){
    target=$1
    n=$2
    mps=$3
    # port=$4
    for i in `seq 1 $n`; do
        sockperf ul --mps=$mps --tcp -i $target -p $(( 24000 + i)) -t 10 -m 1400 > lat_$i.log &
    done   
}


function median() {
        sort -n | awk '
                BEGIN {c=0}
                {nums[c++]=$1}
                END {
                        if (c%2==0) print (nums[int(c/2)-1]+nums[int(c/2)])/2;
                        else print nums[int(c/2)]
                }
        '
}

function sum() {
    paste -sd+ | bc
}

function compute_metrics(){
    path=$1
    pushd $path > /dev/null
    echo -n Bandwidth=
    grep "BandWidth" *.log | tr -d '('  | awk '{ print $(NF-1) }' | sum 
    echo -n Tail Latency=
    grep "99.000" *.log | awk '{ print $NF }' | median
    popd > /dev/null
}

echo "Throughput Eval..."
run_throughput_eval 172.16.66.8 100 max 12345
sleep 15

echo "Latency Eval..."
run_latency_eval 172.16.66.8 100 1000 12345
sleep 15

compute_metrics .
