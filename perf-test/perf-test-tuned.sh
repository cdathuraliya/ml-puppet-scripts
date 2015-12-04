#!/bin/bash

echo "Running tuned samples..."
# write performance results CSV headers
echo "algorithm,t,count,max,mean,min,stddev,p50,p75,p95,p98,p99,p999,mean_rate,m1_rate,m5_rate,m15_rate,rate_unit,duration_unit" | tee perf-results-tuned-model-building.csv > perf-results-tuned-prediction.csv
# declare an array of algorithm folder names
declare -a tuned_algos=("decision-tree" "k-means" "lasso-regression" "linear-regression" "logistic-regression-lbfgs" "logistic-regression-sgd" "naive-bayes" "random-forest" "ridge-regression" "svm")
# declare an array of algorithm names
declare -a algos=("DECISION_TREE" "K_MEANS" "LASSO_REGRESSION" "LINEAR_REGRESSION" "LOGISTIC_REGRESSION_LBFGS" "LOGISTIC_REGRESSION" "NAIVE_BAYES" "RANDOM_FOREST" "RIDGE_REGRESSION" "SVM")

i=0
for tuned_algo in "${tuned_algos[@]}"
do
	if [ "$i" -eq 0 ]; then
		# navigate to tuned samples
		cd tuned/"$tuned_algo"/
	else
		# navigate between algorithms
		cd ../"$tuned_algo"/
	fi

	# run sample script
	sh model-generation.sh
	# wait for carbon metrics polling period
	sleep 70

	# read from carbon-metrics CSVs and write to performance results CSVs
	tail_model_building=$(tail -1 ../../../repository/logs/metrics/org.wso2.carbon.ml.model-building-time."${algos[${i}]}".csv)
	echo "$tuned_algo,$tail_model_building" >> ../../perf-results-tuned-model-building.csv
	# skip prediction for k-means
	if [ "$i" -ne 1 ]; then
		tail_prediction=$(tail -1 ../../../repository/logs/metrics/org.wso2.carbon.ml.prediction-time."${algos[${i}]}".csv)	
		echo "$tuned_algo,$tail_prediction" >> ../../perf-results-tuned-prediction.csv
	fi

	((i++))
done
echo "Tuned samples completed"