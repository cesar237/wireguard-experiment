scripts/reboot-all.sh
for test in download upload; do
    # scripts/run_playbook.sh setup-eval $test-threaded && \
    scripts/run_playbook.sh setup-eval $test && \
    scripts/run_configs.sh $test
done


for run in `ls`; do
    for cpu in `ls $run | grep CPU`; do
        for nflow in `ls $run/$cpu`; do
            perf script -i $run/$cpu/$nflow/perf/perf.data > $run/$cpu/$nflow/perf/out.perf
        done
    done
done

flamegraph_dir=~/Documents/Wireguard/wireguard-kernel/FlameGraph

for run in `ls`; do
    for cpu in `ls $run | grep CPU`; do
        for nflow in `ls $run/$cpu`; do
            $flamegraph_dir/stackcollapse-perf.pl $run/$cpu/$nflow/perf/out.perf >  ../out.kern
            $flamegraph_dir/flamegraph.pl ../out.kern > $run/$cpu/$nflow/perf/graph-$run-$cpu-$nflow.svg
        done
    done
done

find . -iname perf.data