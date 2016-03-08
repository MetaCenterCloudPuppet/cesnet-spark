# == Class spark::params
#
# This class is meant to be called from spark.
# It sets variables according to platform.
#
class spark::params {
  case "${::osfamily}-${::operatingsystem}" {
    /RedHat-Fedora/: {
      $packages = {
        frontend => 'spark',
      }
    }
    /Debian|RedHat/: {
      $daemons = {
        master         => 'spark-master',
        historyserver  => 'spark-history-server',
        worker         => 'spark-worker',
      }
      $packages = {
        common         => 'spark-core',
        master         => 'spark-master',
        frontend       => 'spark-python',
        historyserver  => 'spark-history-server',
        worker         => 'spark-worker',
      }
    }
    default: {
      fail("${::operatingsystem} (${::osfamily}) not supported")
    }
  }

  $confdir = "${::osfamily}-${::operatingsystem}" ? {
    /RedHat-Fedora/ => '/etc/spark',
    /Debian|RedHat/ => '/etc/spark/conf',
  }

  $defaultdir = "${::osfamily}-${::operatingsystem}" ? {
    /RedHat-Fedora/ => '/etc/sysconfig',
    /Debian|RedHat/ => '/etc/default',
  }

  $hive_configfile = "${::osfamily}-${::operatingsystem}" ? {
    /RedHat-Fedora/ => '../etc/hive/hive-site.xml',
    /Debian|RedHat/ => '../../hive/conf/hive-site.xml',
  }

  $keytab_historyserver = '/etc/security/keytab/spark.service.keytab'

  $master_port = '7077'
  $master_ui_port = '18080'
  $worker_port = '7078'
  $worker_ui_port = '18081'
  $historyserver_port = '18088'
}
