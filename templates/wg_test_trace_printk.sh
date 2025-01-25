# $1: root path
# $2: The number of cpu cores
# $3: The number of input flows

root_path=$1
res_path=$root_path/CPU-$2/nflow-$3 
ftrace_path=/sys/kernel/debug/tracing

mkdir -p $res_path
cd $res_path


# Get trace infos
mkdir trace-printk
cd trace-printk

trace-cmd record -p function_graph -l :mod:wireguard --max-graph-depth 1 -e napi -- sleep 10

cd ..

cd $root_path
