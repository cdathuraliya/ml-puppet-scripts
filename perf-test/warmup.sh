#!/bin/bash

echo "Running server warm-up samples..."
# declare an array of algorithm folder names
declare -a default_algos=("decision-tree" "k-means" "lasso-regression" "linear-regression" "logistic-regression-lbfgs" "logistic-regression-sgd" "naive-bayes" "random-forest" "ridge-regression" "svm")

i=0
for default_algo in "${default_algos[@]}"
do
	if [ "$i" -eq 0 ]; then
		# navigate to default samples
		cd warmup/"$default_algo"/
	else
		# navigate between algorithms
		cd ../"$default_algo"/
	fi

	# run sample script
	sh model-generation.sh

	((i++))
done
echo "Server warm-up samples completed"