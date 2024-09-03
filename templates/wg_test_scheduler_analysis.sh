# $1: root path
# $2: The number of cpu cores
# $3: The number of input flows

root_path=$1
res_path=$root_path/CPU-$2/nflow-$3 
ftrace_path=/sys/kernel/debug/tracing

mkdir -p $res_path
cd $res_path


# Get trace infos
mkdir sched
cd sched

# Top level
#mkdir toplevel
#cd toplevel
trace-cmd record -e sched -v -e sched_stat_runtime -- sleep 10
# zip trace.dat.zip trace.dat && rm trace.dat
# echo > $ftrace_path/trace
# echo 1 > $ftrace_path/tracing_on
# cat $ftrace_path/trace_pipe > trace.dat &
# sleep 10 && killall cat
# echo 0 > $ftrace_path/tracing_on
cd ..


cd $root_path
