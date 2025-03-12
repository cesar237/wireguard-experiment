# $1: root path
# $2: The number of cpu cores
# $3: The number of input flows

root_path=$1
res_path=$root_path/CPU-$2/nflow-$3 
ftrace_path=/sys/kernel/debug/tracing
now="date +%H:%M:%S"

mkdir -p $res_path
cd $res_path

#Get sar infos
mkdir sar
cd sar
rm -f sar.data
sar -A -o sar.data 1 > /dev/null &
cd ..


cd $root_path
