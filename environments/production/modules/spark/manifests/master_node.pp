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
class spark::master_node (
  $version 		        = '1.4.1',
  $offset  		        = 0,
  $owner   		        = 'root',
  $group   		        = 'root',
  $target  		        = '/mnt/spark',
  $maintenance_mode             = 'new',
  $clustering                   = false,

) inherits spark::params {

  $deployment_code = 'spark'
  $spark_version  = $version
  $service_code    = 'master_node'
  $spark_home     = "${target}/apache-spark-${spark_version}"

 $service_templates = []

 $common_templates = []

 tag($service_code)

 spark::clean { $deployment_code:
    mode      => $maintenance_mode,
    target    => $spark_home,
    version   => $spark_version,
    service   => $service_code,
  }

 spark::initialize { $deployment_code:
    repo      => $package_repo,
    version   => $spark_version,
    service   => $service_code,
    local_dir => $local_package_dir,
    target    => $target,
    owner     => $owner,
    require   => spark::clean[$deployment_code],
  }

  spark::push_templates {
    $service_templates:
      target    => $spark_home,
      directory => "${deployment_code}/${version}",
      owner     => $owner,
      group     => $group,
      require   => spark::initialize[$deployment_code];
  }

  file { "${target}/spark-1.4.1-bin-hadoop2.6/conf/spark-env.sh":
      ensure    => present,
      owner     => $owner,
      group     => $group,
      mode      => '0775',
      content   => template("${deployment_code}/spark-env.sh.erb"),
      require   => spark::initialize[$deployment_code];
  }
  ->
  file { "${target}/spark-1.4.1-bin-hadoop2.6/ml":
      ensure    => "directory",
      owner     => $owner,
      group     => $group,
      mode      => '0775',
  }
  ->
  file { "${target}/spark-1.4.1-bin-hadoop2.6/ml/org.wso2.carbon.ml.core_1.0.2.jar":
      owner     => $owner,
      group     => $group,
      mode      => '0775',
      source    => "puppet:///modules/spark/org.wso2.carbon.ml.core_1.0.2.jar"
  }
  ->
  file { "${target}/spark-1.4.1-bin-hadoop2.6/ml/org.wso2.carbon.ml.commons_1.0.2.jar":
      owner     => $owner,
      group     => $group,
      mode      => '0775',
      source    => "puppet:///modules/spark/org.wso2.carbon.ml.commons_1.0.2.jar"
  }
  ->
  file { "${target}/spark-1.4.1-bin-hadoop2.6/ml/org.wso2.carbon.ml.database_1.0.2.jar":
      owner     => $owner,
      group     => $group,
      mode      => '0775',
      source    => "puppet:///modules/spark/org.wso2.carbon.ml.database_1.0.2.jar"
  }
  ->
  file { "${target}/spark-1.4.1-bin-hadoop2.6/ml/kryo_2.24.0.wso2v1.jar":
      owner     => $owner,
      group     => $group,
      mode      => '0775',
      source    => "puppet:///modules/spark/kryo_2.24.0.wso2v1.jar"
  }
  ->
  spark::start { $deployment_code:
    target  => $spark_home,
    owner   => $owner,
    java_home => $java_home,
    require  => [
                 spark::initialize[$deployment_code],
                 spark::push_templates[$service_templates],
                 ],
  }
}
