# == Class spark::params
#
# This class is meant to be called from spark.
# It sets variables according to platform.
#
class spark::params {
  case $::osfamily {
    'Debian': {
      $confdir = '/etc/spark/conf'
      $daemons = {
        historyserver  => 'spark-history-server',
      }
      $defaultdir = '/etc/default'
      $packages = {
        common         => 'spark-core',
        frontend       => 'spark-python',
        historyserver  => 'spark-history-server',
      }
    }
    'RedHat': {
      $confdir = '/etc/spark'
      $defaultdir = '/etc/sysconfig'
      $packages = {
        frontend => 'spark'
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  $alternatives = "${::osfamily}-${::operatingsystem}" ? {
    /RedHat-Fedora/ => undef,
    # https://github.com/puppet-community/puppet-alternatives/issues/18
    /RedHat/        => '',
    /Debian/        => 'cluster',
  }

  $keytab_historyserver = '/etc/security/keytab/spark.service.keytab'
}
