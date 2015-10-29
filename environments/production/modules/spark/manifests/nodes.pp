node /master/ {
 class { "spark::master":
  version => "1.4.1",
  owner => "root",
  group => "root",
  maintenance_mode => "new"
 }
}
