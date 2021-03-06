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
# Cleans the previous deployment. If the maintenance mode is set to true, this will only kill the running service.

define spark::clean ($mode, $target, $service, $version) {
  if $mode == 'refresh' {
    exec{
      "Stop_process_${name}":
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/',
        command => "kill $(ps aux | grep '[s]park' | awk '{print $2}')";
    }
  }
  elsif $mode == 'new' {
    exec { "Stop_process_and_remove_SPARK_HOME_${name}":
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/',
        command => "kill $(ps aux | grep '[s]park' | awk '{print $2}') ; rm -rf ${target}";
    }
  }
  elsif $mode == 'zero' {
    exec { "Stop_process_remove_SPARK_HOME_and_pack_${name}":
        path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin/',
        command => "kill $(ps aux | grep '[s]park' | awk '{print $2}') ; rm -rf ${target} ; rm -f ${::local_package_dir}/spark-1.4.1-bin-hadoop2.6.tgz";
    }
  }
}
