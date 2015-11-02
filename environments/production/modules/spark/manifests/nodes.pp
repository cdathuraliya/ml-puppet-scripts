node /master-node/ {
 class { "spark::master-node":
  version => "1.4.1",
  owner => "root",
  group => "root",
  maintenance_mode => "new"
 }
}
