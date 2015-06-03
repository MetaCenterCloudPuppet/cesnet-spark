# == Class spark::params
#
# This class is meant to be called from spark.
# It sets variables according to platform.
#
class spark::params {
  case "${::osfamily}-${::operatingsystem}" {
    /RedHat-Fedora/: {
      $packages = {
        frontend => 'spark'
      }
    }
    /Debian|RedHat/: {
      $daemons = {
        historyserver  => 'spark-history-server',
      }
      $packages = {
        common         => 'spark-core',
        frontend       => 'spark-python',
        historyserver  => 'spark-history-server',
      }
    }
    default: {
      fail("${::operatingsystem} (${::osfamily}) not supported")
    }
  }

  $alternatives = "${::osfamily}-${::operatingsystem}" ? {
    /RedHat-Fedora/ => undef,
    # https://github.com/puppet-community/puppet-alternatives/issues/18
    /RedHat/        => '',
    /Debian/        => 'cluster',
  }

  $confdir = "${::osfamily}-${::operatingsystem}" ? {
    /RedHat-Fedora/ => '/etc/spark',
    /Debian|RedHat/ => '/etc/spark/conf',
  }

  $defaultdir = "${::osfamily}-${::operatingsystem}" ? {
    /RedHat-Fedora/ => '/etc/sysconfig',
    /Debian|RedHat/ => '/etc/default',
  }

  $keytab_historyserver = '/etc/security/keytab/spark.service.keytab'
}
