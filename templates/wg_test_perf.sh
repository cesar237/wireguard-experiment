# $1: root path
# $2: The number of cpu cores
# $3: The number of input flows

root_path=$1
res_path=$root_path/CPU-$2/nflow-$3 
ftrace_path=/sys/kernel/debug/tracing

mkdir -p $res_path
cd $res_path


# Get trace infos
mkdir perf
cd perf

perf record -F 998 -a -g -- sleep 5
perf script > out.perf

# trace-cmd record -p nop -e napi -e sched -v -e sched_stat_runtime -- sleep 7

cd ..


cd $root_path
