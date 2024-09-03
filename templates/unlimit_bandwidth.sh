for i in `seq 1 40`; do
    tc qdisc del dev wg-$i root 2>&1 /dev/null
done
