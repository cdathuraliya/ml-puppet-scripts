node /hadoopserver/ {
 class { "hadoop::hdfs_node":
  version => "2.6.0",
  owner => "root",
  group => "root",
  maintenance_mode => "new`"
 }
}
