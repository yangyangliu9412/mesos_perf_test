#!/bin/bash
DATE=$(date +%Y-%m-%d-%H-%M-%S)
FILE_RESULTS="marathon-mesos-test-results-$DATE"
#MARATHON_URL="http://127.0.0.1:8080/marathon"
MARATHON_URL="http://18.216.89.143:8080"
TOP_DIR=$(cd $(dirname "$0") && pwd)
LOGLEVEL="DEBUG"
cd ${TOP_DIR}

virtualenv --python=/usr/local/bin/python2.7 .venv
VPYTHON=".venv/bin/python"
.venv/bin/pip install -r requirements.txt
echo "install requirement package success"
echo "[" > ${FILE_RESULTS}.json
for test in create update_cpu update_mem update_disk update_instances restart delete; do
    for concur in 1 2 4 8 16; do
        for nodes in 1 10 50 100 500; do
            echo "$(date) - Start test $test with concurrency $concur with $nodes nodes"
            #$VPYTHON marathon-scale-tests.py -l $LOGLEVEL -m $MARATHON_URL -t${test} -c${concur} -n${nodes} -s >> ${FILE_RESULTS}.json
	    $VPYTHON marathon-scale-tests.py -l $LOGLEVEL -m $MARATHON_URL -t${test} -c${concur} -n${nodes} -s
            # If something wrong, clean all
            sleep 30
            $VPYTHON application_managment_helper.py  -m $MARATHON_URL -edelete
        done
    done
done
sed -i '$ s/.$//' ${FILE_RESULTS}.json
echo "]" >> ${FILE_RESULTS}.json
