node /hdfs-node/ {
 class { "hadoop::hdfs-node":
  version => "2.6.0",
  owner => "root",
  group => "root",
  maintenance_mode => "new`"
 }
}
