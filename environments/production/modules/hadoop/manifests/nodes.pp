node /hadoopserver/ {
 $serverinfo = hiera("hdfsnode")
 class { "hadoop::hdfs_node":
  version => "2.6.0",
  owner => "root",
  group => "root",
  maintenance_mode => "new",
  hdfs_url => $serverinfo[hdfs_url]
 }
}
