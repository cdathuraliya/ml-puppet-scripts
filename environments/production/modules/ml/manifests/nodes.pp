node /mlserver/ {
 $serverinfo = hiera("servernode")
 class { "ml::server_node":
  version => "1.0.0",
  owner => "root",
  group => "root",
  maintenance_mode => "zero",
  storage_type => $serverinfo[storage_type],
  spark_master => $serverinfo[spark_master],
  dataset_directory => $serverinfo[dataset_directory],
  model_directory => $serverinfo[model_directory],
 }
}
