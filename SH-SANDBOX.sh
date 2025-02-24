scripts/deploy_env.sh && scripts/install_kernel.sh
scripts/reboot-all.sh
modes="-wq -threaded -threaded-pinned"
mode="-threaded-pinned"
mode=""

https://github.com/cesar237/encryptonce.git

scripts/reboot-all.sh

scripts/deploy_env.sh
cases="upload"
modes="yes no"
# modes=partial
# versions="kernel kernel-threaded"
versions="kernel-v1"
for version in $versions; do
for case in $cases; do
for mode in $modes; do
    test=${case}--${mode}-${version}
    echo $test
    # scripts/deploy_env.sh
    scripts/run_playbook.sh setup-eval $test && \
    scripts/run_configs.sh $test
done
done
done

scripts/deploy_env.sh
cases="upload"
modes="yes no"
# modes=partial
# versions="kernel kernel-threaded"
versions="kernel-v1"
for version in $versions; do
for case in $cases; do
for mode in $modes; do
    test=${case}--${mode}-${version}
    echo $test
    # scripts/deploy_env.sh
    scripts/run_playbook.sh setup-eval $test && \
    scripts/run_configs.sh $test
done
done
done

./scripts/deploy_env.sh
case="upload"
mode="no"
version="kernel-v1"
test=${case}--${mode}-${version}
echo $test
# scripts/deploy_env.sh
scripts/run_playbook.sh setup-eval $test && \
scripts/run_configs.sh $test

test=upload-kernel-find-max
scripts/run_playbook.sh setup-eval $test && \
scripts/run_configs.sh $test

scripts/reboot-all.sh
eval=upload--yes-kernel-v1
scripts/run_playbook.sh setup-eval ${eval} && \
scripts/run_configs.sh ${eval}



eval=upload--partial-go--tcp
scripts/run_playbook.sh setup-eval ${eval} && \
scripts/run_configs.sh ${eval}

ssh root@$server "cd /tmp; zip -r linux-6.1.90-imp2.zip linux-6.1.90"
scp root@$server:/tmp/linux-6.1.90-imp2.zip wireguard-artefacts/

scripts/run_playbook.sh setup-eval upload && \
scripts/run_configs.sh upload

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
