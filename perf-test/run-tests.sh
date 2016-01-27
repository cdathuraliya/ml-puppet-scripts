#!/bin/bash
# server IP source
. server.conf

# declare an array of tuned algorithm folder names
declare -a tuned_algos=()
# declare an array of default algorithm folder names
declare -a default_algos=()

# read algorithm folder names and algorithm names from algo-info.conf file
IFS=":"
while read -r algo name sample_type || [ -n "$algo" ]; do
    if [[ ${sample_type} == *"tuned"* ]]; then
        tuned_algos+=(${algo})
    else
        default_algos+=(${algo})
    fi
done < algo-info.conf

echo "Creating directories..."
rm -rf perf-test
mkdir perf-test
# copy tuned and defaults samples to a single directory
i=0
for tuned_algo in "${tuned_algos[@]}"
do
    cp -r tuned/"$tuned_algo"/ perf-test/
    ((i++))
done

j=0
for default_algo in "${default_algos[@]}"
do
    cp -r default/"$default_algo"/ perf-test/
    ((j++))
done

echo "Starting performance tests..."
# disable carbon metrics
jrunscript -cp org.wso2.carbon.metrics.manager-1.1.1.jar metrics_jmx_operations.js $SEVER_IP 11111 9999 admin admin disable
echo "Carbon Metrics disabled for warm-up samples"
# run server warm-up samples
./warmup.sh
# enable carbon metrics
jrunscript -cp org.wso2.carbon.metrics.manager-1.1.1.jar metrics_jmx_operations.js enable
echo "Carbon Metrics enabled for tuned samples"
# running tuned samples
./perf-test.sh
echo "Performance tests completed"
