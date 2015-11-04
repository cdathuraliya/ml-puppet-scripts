node /server-node/ {
 class { "ml::server-node":
  version => "1.0.0",
  owner => "root",
  group => "root",
  maintenance_mode => "new"
 }
}
