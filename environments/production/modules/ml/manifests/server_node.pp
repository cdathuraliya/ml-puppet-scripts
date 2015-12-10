#
# Copyright (c) 2015, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ----------------------------------------------------------------------------
#
# Class: ML
#
# This class installs WSO2 ML
#
# Parameters:
#
# version            => '1.0.0',
# offset             => 0,
# owner              => 'wso2',
# group              => 'wso2',
# target             => '/mnt/',
#
# Actions:
#   - Install WSO2 ML
#
# Requires:
#
# Sample Usage:
#

class ml::server_node (
  $version 		        = '1.0.0',
  $offset  		        = 0,
  $owner   		        = 'root',
  $group   		        = 'root',
  $target  		        = '/mnt/packs',
  $maintenance_mode             = 'new',
  $clustering                   = false,
  $storage_type                 = 'file',
  $spark_master                 = 'local',
  $hdfs_url                     = 'hdfs://localhost:9000/ml',
  $dataset_directory            = '${target}/wso2ml-${carbon_version}/datasets',
  $model_directory              = '${target}/wso2ml-${carbon_version}/models'

) inherits ml::params {

  $deployment_code = 'ml'
  $carbon_version  = $version
  $service_code    = 'ml'
  $carbon_home     = "${target}/wso2${service_code}-${carbon_version}"

 $service_templates = ['conf/metrics.xml', 'conf/machine-learner.xml', 'conf/etc/spark-config.xml']

 $common_templates = []

 tag($service_code)

 ml::clean { $deployment_code:
    mode      => $maintenance_mode,
    target    => $carbon_home,
    version   => $carbon_version,
    service   => $service_code,
  }

 ml::initialize { $deployment_code:
    repo      => $package_repo,
    version   => $carbon_version,
    service   => $service_code,
    local_dir => $local_package_dir,
    target    => $target,
    owner     => $owner,
    require   => ml::clean[$deployment_code],
  }

  ml::deploy { $deployment_code:
    service  => $deployment_code,
    owner    => $owner,
    group    => $group,
    target   => $carbon_home,
    require  => ml::initialize[$deployment_code],
  }

  ml::push_templates {
    $service_templates:
      target    => $carbon_home,
      directory => "${deployment_code}/${version}",
      owner     => $owner,
      group     => $group,
      require   => ml::deploy[$deployment_code];

    $common_templates:
      target     => $carbon_home,
      directory  => "wso2base",
      owner     => $owner,
      group     => $group,
      require    => ml::deploy[$deployment_code];
  }
  ->
  file { ["${target}/wso2${service_code}-${carbon_version}/datasets", "${target}/wso2${service_code}-${carbon_version}/models"]:
      ensure    => directory,
      owner     => $owner,
      group     => $group,
      mode      => '0775',
      require   => ml::initialize[$deployment_code],
  }
  ->
  ml::start { $deployment_code:
    target  => "${target}/wso2${service_code}-${carbon_version}",
    owner   => $owner,
    require  => [
                 ml::initialize[$deployment_code],
                 ml::push_templates[$service_templates],
                 ],
  }
}
