#!/bin/bash

# server IP source
. server.conf

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
./perf-test-tuned.sh
echo "Performance tests completed"