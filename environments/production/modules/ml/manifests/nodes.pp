node /standalone-ml/ {
 class { "ml::standalone-ml":
  version => "1.0.0",
  owner => "root",
  group => "root",
  maintenance_mode => "new"
 }
}
