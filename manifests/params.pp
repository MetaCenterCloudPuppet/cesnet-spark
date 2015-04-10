# == Class spark::params
#
# This class is meant to be called from spark.
# It sets variables according to platform.
#
class spark::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'spark'
      $service_name = 'spark'
    }
    'RedHat', 'Amazon': {
      $package_name = 'spark'
      $service_name = 'spark'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
