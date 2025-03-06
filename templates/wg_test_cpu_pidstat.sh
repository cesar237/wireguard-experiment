# $1: root path
# $2: The number of cpu cores
# $3: The number of input flows

root_path=$1
res_path=$root_path/CPU-$2/nflow-$3
now="date +%H:%M:%S"

mkdir -p $res_path
cd $res_path


#Get sar infos
mkdir pidstat
cd pidstat
rm -f pidstat.data
pidstat 1 > pidstat.data &
# sar -A -o sar.data 1 60 > /dev/null
cd ..

cd $root_path
