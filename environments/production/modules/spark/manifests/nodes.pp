node /sparkmaster/ {
 class { "spark::master_node":
  version => "1.4.1",
  owner => "root",
  group => "root",
  maintenance_mode => "new"
 }
}
