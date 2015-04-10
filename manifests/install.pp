# == Class spark::install
#
# This class is called from spark for install.
#
class spark::install {

  package { $::spark::package_name:
    ensure => present,
  }
}
