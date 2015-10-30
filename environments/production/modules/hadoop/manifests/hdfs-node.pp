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
# Class: Hadoop
#
# This class installs Apache Hadoop
#
# Parameters:
#
# version            => '2.6.0',
# owner              => 'root',
# group              => 'root',
# target             => '/mnt/',
#
# Actions:
#   - Install Apache Hadoop
#
# Requires:
#
# Sample Usage:
#
class hadoop::hdfs-node (
  $version 		        = '2.6.0',
  $offset  		        = 0,
  $owner   		        = 'root',
  $group   		        = 'root',
  $target  		        = '/mnt/hadoop',
  $maintenance_mode             = 'new',
  $clustering                   = false,

) inherits hadoop::params {

  $deployment_code = 'hadoop'
  $hadoop_version  = $version
  $service_code    = 'hdfs-node'
  $hadoop_home     = "${target}/apache-hadoop-${hadoop_version}"

 $service_templates = []

 $common_templates = []

 tag($service_code)

 hadoop::clean { $deployment_code:
    mode      => $maintenance_mode,
    target    => $hadoop_home,
    version   => $hadoop_version,
    service   => $service_code,
  }

 hadoop::initialize { $deployment_code:
    repo      => $package_repo,
    version   => $hadoop_version,
    service   => $service_code,
    local_dir => $local_package_dir,
    target    => $target,
    owner     => $owner,
    require   => hadoop::clean[$deployment_code],
  }

  hadoop::push_templates {
    $service_templates:
      target    => $hadoop_home,
      directory => "${deployment_code}/${version}",
      owner     => $owner,
      group     => $group,
      require   => hadoop::initialize[$deployment_code];
  }

  file { "${target}/hadoop-2.6.0/etc/hadoop/hadoop-env.sh":
      ensure    => present,
      owner     => $owner,
      group     => $group,
      mode      => '0775',
      content   => template("${deployment_code}/hadoop-env.sh.erb"),
  }

  hadoop::start { $deployment_code:
    target  => $hadoop_home,
    owner   => $owner,
    java_home => $java_home,
    require  => [
                 hadoop::initialize[$deployment_code],
                 hadoop::push_templates[$service_templates],
                ],
  }
}
