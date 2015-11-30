#
# Currently there are three ways to setup the WSO2 product cluster
#
# 1. Trigger deployment from jenkins using MCollective (as the controller)
# 2. Trigger deployment from puppet master using MCollective
# 3. Trigger deployment from each puppet agent using the setup.sh script provided
#
# Load initial data and define stages
import "wso2base/loaddata"

# Default node definition
import "wso2base/defaultnode"

# wso2base node definition
import "wso2base/basenode"

# Loadbalancer configurations
import "wso2base/loadbalancer"

# Database server definition
import "wso2base/dbserver"

# Jenkins definitions
import "wso2base/jenkins"

import "ml/nodes"

import "spark/nodes"

import "hadoop/nodes"

