#!/bin/bash
echo "Running server warm-up tests..."

# declare an array of algorithm folder names
declare -a all_algos=()
# read algorithm folder names from algo-info.conf file
IFS=":"
while read -r algo name sample_type || [ -n "$algo" ]; do
    all_algos+=(${algo})
done < algo-info.conf

i=0
for algo in "${all_algos[@]}"
do
    if [ "$i" -eq 0 ]; then
        # navigate to perf-test directory
        cd perf-test/"$algo"/
    else
        # navigate between algorithms
        cd ../"$algo"/
    fi
    # run sample script
    ./model-generation.sh wmp
    ((i++))
done
echo "Server warm-up tests completed"
