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

trace-cmd record -p function_graph -l wg_packet_encrypt_worker -l wg_packet_decrypt_worker -l wg_packet_tx_worker -l wg_packet_rx_poll --max-graph-depth 1 -e napi -e sched -v -e sched_stat_runtime -- sleep 5

cd ..

cd $root_path
