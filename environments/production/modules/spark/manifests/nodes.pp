node /sparkmaster/ {
 $serverinfo = hiera("masternode")
 class { "spark::master_node":
  version => "1.4.1",
  owner => "root",
  group => "root",
  maintenance_mode => "new",
  spark_ip => $serverinfo[spark_ip],
 }
}
