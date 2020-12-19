# == Class: spark
#
# Main configuration class for CESNET Apache Spark puppet module.
#
class spark (
  $alternatives = '::default',
  $defaultFS = '::default',
  $logdir = '/user/spark/applicationHistory',
  $master_hostname = undef,
  $master_port = $::spark::params::master_port,
  $master_ui_port = $::spark::params::master_ui_port,
  $historyserver_hostname = undef,
  $historyserver_port = $::spark::params::historyserver_port,
  $worker_port = $::spark::params::worker_port,
  $worker_ui_port = $::spark::params::worker_ui_port,
  $environment = undef,
  $properties = undef,
  $realm = undef,
  $hive_enable = true,
  $jar_enable = false,
  $yarn_enable = true,
  $confdif = $::spark::params::confdir,
  $hive_configfile = $::spark::params::hive_configfile,
  $keytab = '/etc/security/keytab/spark.service.keytab',
  $keytab_source = undef,
) inherits ::spark::params {
  if ($defaultFS == '::default') {
    $_defaultFS = $::hadoop::_defaultFS
  } else {
    $_defaultFS = $defaultFS
  }
  if $jar_enable and !$_defaultFS {
    warn('Hadoop defaultFS or defaultFS parameter needed, when remote copied jar enabled')
  }

  if $_defaultFS and $_defaultFS != '' {
    $event_properties = {
      'spark.eventLog.enabled' => 'true',
      'spark.eventLog.dir' => "${_defaultFS}${logdir}",
    }
  } else {
    $event_properties = {}
  }
  if $jar_enable {
    $jar_properties = {
      'spark.yarn.jar' => "${_defaultFS}/user/spark/share/lib/spark-assembly.jar",
    }
  } else {
    $jar_properties = {}
  }
  if $yarn_enable {
    $master_properties = {
      'spark.master' => 'yarn',
    }
  } else {
    if $master_hostname and $master_hostname != '' {
      $master_properties = {
        'spark.master' => "spark://${master_hostname}:${master_port}",
      }
    } else {
      $master_properties = {}
    }
  }
  if $historyserver_hostname {
    $hs_properties = {
      # must be with 'http://' to proper redirection from Hadoop with security
      'spark.yarn.historyServer.address' => "http://${historyserver_hostname}:${historyserver_port}",
      'spark.history.fs.logDirectory' => $logdir,
    }
  } else {
    $hs_properties = {}
  }
  if $historyserver_hostname == $::fqdn {
    $hs_daemon_properties = {
      'spark.history.ui.port' => $historyserver_port,
    }
  } else {
    $hs_daemon_properties = {}
  }
  if $realm and $realm != '' {
    if $historyserver_hostname == $::fqdn {
      $security_properties = {
        'spark.history.kerberos.enabled' => true,
        'spark.history.kerberos.keytab' => $keytab,
        'spark.history.kerberos.principal' => "spark/${::fqdn}@${realm}",
      }
    } else {
      $security_properties = {}
    }
  } else {
    $security_properties = {}
  }

  $_properties = merge($event_properties, $jar_properties, $master_properties, $hs_properties, $hs_daemon_properties, $security_properties, $properties)
}
