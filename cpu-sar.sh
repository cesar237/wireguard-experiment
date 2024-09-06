#! /bin/bash


if [ -z "$1" ]; then
    echo "Please put a run_dir path here..."
    exit 1
else
    run_dir=$1
fi
curr=`pwd`

cd $run_dir

echo "cpu,client,core,usr,kernel,softirq,idle"

for cpu in $(ls | grep CPU); do
    ncpu=$(echo $cpu | cut -d "-" -f 2)

    for flow in $(ls $cpu); do
        nflow=$(echo $flow | cut -d "-" -f 2)

        sadf -d $cpu/$flow/sar/sar.data -- -u ALL -P ALL \
        | tail -n +2 \
        | awk -v cpu=$ncpu -v flow=$nflow 'BEGIN{FS=";"} {print cpu,flow,$4,$5,$7,$11,$14}' \
        | tr ',' '.' \
        | tr ' ' ','
    done
done

cd $curr