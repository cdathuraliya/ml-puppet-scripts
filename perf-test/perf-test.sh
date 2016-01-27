#!/bin/bash
echo "Running performance tests..."
# write performance results CSV headers
echo "algorithm,t,count,max,mean,min,stddev,p50,p75,p95,p98,p99,p999,mean_rate,m1_rate,m5_rate,m15_rate,rate_unit,duration_unit" | tee perf-results-model-building.csv > perf-results-prediction.csv

# declare an array of algorithm folder names
declare -a all_algos=()
# declare an array of algorithm names as given in carbon metrics log files
declare -a algos=()

# read algorithm folder names and algorithm names from algo-info.conf file
IFS=":"
while read -r algo name sample_type || [ -n "$algo" ]; do
    all_algos+=(${algo})
    algos+=(${name})
done < algo-info.conf

i=0
for algo in "${all_algos[@]}"
do
    if [ "$i" -eq 0 ]; then
        # navigate to tuned samples
        cd perf-test/"$algo"/
    else
        # navigate between algorithms
        cd ../"$algo"/
    fi
    # run sample script
    ./model-generation.sh perf
    # wait for carbon metrics polling period
    sleep 70
    # read from carbon-metrics CSVs and write to performance results CSVs
    tail_model_building=$(tail -1 ../../../repository/logs/metrics/org.wso2.carbon.ml.model-building-time."${algos[${i}]}".csv)
    echo "$algo,$tail_model_building" >> ../../perf-results-model-building.csv
    # skip prediction
    if [ "$algo" != "collaborative-filtering" ] && [ "$algo" != "collaborative-filtering-implicit" ] && [ "$algo" != "k-means" ]; then
        tail_prediction=$(tail -1 ../../../repository/logs/metrics/org.wso2.carbon.ml.prediction-time."${algos[${i}]}".csv)	
        echo "$algo,$tail_prediction" >> ../../perf-results-prediction.csv
    fi
    ((i++))
done
echo "Performance tests completed"
