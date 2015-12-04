#!/bin/bash

printf "\nRunning DECISION TREE workflow..."

# server IP source
. ../../server.conf

# die on any error
set -e

DIR="${BASH_SOURCE%/*}"; if [ ! -d "$DIR" ]; then DIR="$PWD"; fi; . "$DIR/../../base.sh"

# create the dataset
path=$(pwd)
curl -s -X POST -b cookies  https://$SEVER_IP:9443/api/datasets -H "Authorization: Basic YWRtaW46YWRtaW4=" -H "Content-Type: multipart/form-data" -F datasetName='gammaTelescope-decision-tree-dataset' -F version='2.0.0' -F description='Gamma Telescope Dataset' -F sourceType='file' -F destination='file' -F dataFormat='CSV' -F containsHeader='true' -F file=@'/'$path'/gammaTelescope.csv' -k
sleep 5

# create a project
curl -s -X POST -d @'create-project' -H "Content-Type: application/json" -H "Authorization: Basic YWRtaW46YWRtaW4=" https://$SEVER_IP:9443/api/projects -k
sleep 2

# get the project
project=$(curl -s -H "Content-Type: application/json" -H "Authorization: Basic YWRtaW46YWRtaW4=" https://$SEVER_IP:9443/api/projects/wso2-ml-decision-tree-tuned-sample-project -k)
sleep 2

# update the json file with retrieved values
projectId=$(echo "$project"|jq '.id')
datasetId=$(echo "$project"|jq '.datasetId')
${SED} -i 's/^\("projectId":"\)[^"]*/\1'$projectId/ create-analysis;
sleep 2

# create an analysis
curl -s -X POST -d @'create-analysis' -H "Content-Type: application/json" -H "Authorization: Basic YWRtaW46YWRtaW4=" https://$SEVER_IP:9443/api/analyses -k
sleep 2

# get analysis ID
analysis=$(curl -s -H "Content-Type: application/json" -H "Authorization: Basic YWRtaW46YWRtaW4=" https://$SEVER_IP:9443/api/projects/${projectId}/analyses/wso2-ml-decision-tree-tuned-sample-analysis -k)
sleep 2

analysisId=$(echo "$analysis"|jq '.id')

# set model configurations
curl -s -X POST -d @'create-model-config' -H "Content-Type: application/json" -H "Authorization: Basic YWRtaW46YWRtaW4=" https://$SEVER_IP:9443/api/analyses/${analysisId}/configurations -k
sleep 2

# add default features with customized options
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Basic YWRtaW46YWRtaW4=" https://$SEVER_IP:9443/api/analyses/${analysisId}/features/defaults -k -d @'customized-features'
sleep 2

# set default hyper-parameters
curl -s -X POST -d @'hyper-parameters' -H "Content-Type: application/json" -H "Authorization: Basic YWRtaW46YWRtaW4=" https://$SEVER_IP:9443/api/analyses/${analysisId}/hyperParams?algorithmName=DECISION_TREE -k
sleep 2

# get dataset version
datasetVersions=$(curl -s -H "Content-Type: application/json" -H "Authorization: Basic YWRtaW46YWRtaW4=" https://$SEVER_IP:9443/api/datasets/${datasetId}/versions -k)
sleep 2

# update the json file
datasetVersionId=$(echo "$datasetVersions"|jq '.[0] .id')
${SED} -i 's/^\("analysisId":"\)[^"]*/\1'$analysisId/ create-model;
sleep 2
${SED} -i 's/^\("versionSetId":"\)[^"]*/\1'$datasetVersionId/ create-model;
sleep 2

for i in `seq 1 3`; do
	printf "\n--- Running build iteration: $i"
	# create a model
	model=$(curl -s -X POST -d @'create-model' -H "Content-Type: application/json" -H "Authorization: Basic YWRtaW46YWRtaW4=" https://$SEVER_IP:9443/api/models -k)
	sleep 2

	# get the model
	modelName=$(echo "$model"|jq -r '.name')
	model=$(curl -s -H "Content-Type: application/json" -H "Authorization: Basic YWRtaW46YWRtaW4=" https://$SEVER_IP:9443/api/models/${modelName} -k)
	sleep 2
	modelId=$(echo "$model"|jq '.id')

	# build the model
	curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Basic YWRtaW46YWRtaW4=" https://$SEVER_IP:9443/api/models/${modelId} -k
	sleep 30

	# predict using the model
	printf "\n--- Prediction: "
	curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Basic YWRtaW46YWRtaW4=" https://$SEVER_IP:9443/api/models/${modelId}/predict -k -d @'prediction-test'
done

printf "\nDECISION TREE workflow completed"