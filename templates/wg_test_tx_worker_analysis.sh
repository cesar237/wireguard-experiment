# $1: root path
# $2: The number of cpu cores
# $3: The number of input flows

root_path=$1
res_path=$root_path/CPU-$2/nflow-$3 
ftrace_path=/sys/kernel/debug/tracing

mkdir -p $res_path
cd $res_path

# Get trace infos
mkdir -p wg_tx_worker
cd wg_tx_worker

# Top level
#mkdir toplevel
#cd toplevel
# trace-cmd reset # takes approximatively 1.5 seconds
trace-cmd record -p function_graph -g wg_packet_tx_worker --max-graph-depth 2 -- sleep 10
# echo > $ftrace_path/trace
# echo 1 > $ftrace_path/tracing_on
# cat $ftrace_path/trace_pipe > trace.dat &
# sleep 10 && killall cat
# echo 0 > $ftrace_path/tracing_on
cd ..

cd $root_path
