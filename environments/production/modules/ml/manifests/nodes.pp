node /server-node/ {
 $serverinfo = hiera("servernode")
 class { "ml::server-node":
  version => "1.0.0",
  owner => "root",
  group => "root",
  maintenance_mode => "new",
  storage_type => $serverinfo[storage_type],
  spark_master => $serverinfo[spark_master],
 }
}
