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

class ml::server-node (
  $version 		        = '1.0.0',
  $offset  		        = 0,
  $owner   		        = 'root',
  $group   		        = 'root',
  $target  		        = '/mnt/packs',
  $maintenance_mode             = 'new',
  $clustering                   = false,
  $storage_type                 = 'file',
  $spark_master                 = 'local',
  $dataset_directory            = '/mnt/packs/wso2ml-1.0.0/datasets',
  $model_directory              = '/mnt/packs/wso2ml-1.0.0/models'

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

  file { "/etc/init.d/wso2${service_code}":
      ensure    => present,
      owner     => $owner,
      group     => $group,
      mode      => '0775',
      content   => template("${deployment_code}/wso2${service_code}.erb"),
  }

  service { "wso2${service_code}":
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
      enable     => true,
      require    => [
            initialize[$deployment_code],
            deploy[$deployment_code],
            push_templates[$service_templates],
            file["/etc/init.d/wso2${service_code}"],
      ]
  }
}
