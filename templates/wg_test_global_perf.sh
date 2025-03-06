# $1: root path
# $2: The number of cpu cores
# $3: The number of input flows

root_path=$1
res_path=$root_path/CPU-$2/nflow-$3 
ftrace_path=/sys/kernel/debug/tracing
now="date +%H:%M:%S"

mkdir -p $res_path
cd $res_path


#mkdir ethtool
#cd ethtool
#for i in `seq 1 6000`; do
#    touch ethtool.log
#    echo [`$now`] >> ethtool.log
#    ethtool -S {{ iface }} | egrep "rx([0-9]+)_(packets|bytes)" >> ethtool.data
#    sleep 0.001
#done

#cat /proc/interrupts > mappings.csv
#cd ..

# mkdir cpustat
# cd cpustat
# ncpu=`nproc`
# lines=$(( ncpu + 1 ))
# for i in `seq 1 1000`; do
#     # touch ethtool.log
#     # echo [`$now`] >> ethtool.log
#     head -n $lines /proc/stat >> cpustat.data
#     # ethtool -S {{ iface }} | egrep "rx([0-9]+)_(packets|bytes)" >> ethtool.data
#     sleep 0.01
# done
# cat /proc/interrupts > mappings.csv
# cd ..

# mkdir interruptstat
# cd interruptstat
# ncpu=`nproc`
# lines=$(( ncpu + 1 ))
# for i in `seq 1 1000`; do
#     # touch ethtool.log
#     # echo [`$now`] >> ethtool.log
#     head -n $lines /proc/interrupts >> interrupts.data
#     # ethtool -S {{ iface }} | egrep "rx([0-9]+)_(packets|bytes)" >> ethtool.data
#     sleep 0.01
# done
# # cat /proc/interrupts > mappings.csv
# cd ..

#Get sar infos
mkdir sar
cd sar
rm -f sar.data
sar -A -o sar.data 1 > /dev/null &
cd ..

# mkdir ethtool
# cd ethtool
# echo "rx_packets,tx_packets,tx_packets_phy,rx_packets_phy" > packets.csv
# duration=1
# while [[ $duration -le 10 ]]; do 
# 	ethtool -S {{ iface }} \
# 	| grep \[r\|t\]x_packets \
# 	| tr ":" " " \
# 	| awk '{ print $1,$2 }' \
# 	| tr " " "," \
# 	| csvtool transpose - \
# 	| tail -1 >> packets.csv
# 	sleep 1; 
#     duration=$((duration+1))
# done
# cd ..

cd $root_path
