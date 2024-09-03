
tests=`cat test_list`
server=`cat SERVER`

inv_dir=

if [ ! -d  "$1" ]; then
    echo "Please, enter a directory..."
    exit 1;
fi


echo > test.logs

for test in $tests; do
    echo ---------------------------- >> test.logs
    echo        $test >> test.logs
    echo ---------------------------- >> test.logs

    echo "Creating test output directory..." >> test.logs
    mkdir -p outputs/$test 

    echo "Defining the sleep time of the test..." >> test.logs
    if [[ $test == *"latency"* ]]; then
        sleep_time=270
    else
        sleep_time=110
    fi

    echo "Launching test with corresponding inventory..." >> test.logs

    echo Test existence of inventory files: >> test.logs
    echo -n "$1/inventory-$test.yaml : " >> test.logs
    if [ -f "$1/inventory-$test.yaml" ]; then
        echo exists >> test.logs
    else
        echo "not exists" >> test.logs
    fi

    echo sleeptime=$sleep_time >> test.logs

    echo >> test.logs

    for i in `seq 1 2`; do 
        kareboot3 simple
        for client in `cat CLIENTS`; do
            ssh root@$client "rm ~/test.log"
        done
        ansible-playbook -i $1/inventory-$test.yaml wg.playbook.yaml -f 8; 
        sleep $sleep_time; 
        ssh root@$server "wg-quick down confs/wg.conf"; 
        ssh root@$server "cd /tmp; rm *.zip; zip -r outputs.zip results; ./analyse.sh ."; 
        mkdir -p outputs/$test/run$i; 
        scp root@$server:/tmp/data.zip outputs/$test/run$i; 
        scp root@$server:/tmp/outputs.zip outputs/$test/run$i; 
        for client in `cat CLIENTS`; do
            ssh root@$client "zip -r client-data.zip /tmp/results"; 
            scp root@$client:~/client-data.zip outputs/$test/run$i/client-data-$client.zip;
            scp root@$client:~/test.log outputs/$test/run$i/test-log-$client.txt;
        done
    done
done
