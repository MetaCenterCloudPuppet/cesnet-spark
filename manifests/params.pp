# == Class spark::params
#
# This class is meant to be called from spark.
# It sets variables according to platform.
#
class spark::params {
  case $::osfamily {
    'Debian': {
      $alternatives = 'cluster'
      $confdir = '/etc/spark/conf'
      $packages = {
        frontend => 'spark-python'
      }
    }
    'RedHat': {
      $alternatives = undef
      $confdir = '/etc/spark'
      $packages = {
        frontend => 'spark'
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

}
