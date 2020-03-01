# == Class: spark
#
# Main configuration class for CESNET Apache Spark puppet module.
#
class spark (
  $alternatives = '::default',
  $defaultFS = '::default',
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
) inherits ::spark::params {
  if ($defaultFS == '::default') {
    $_defaultFS = $::hadoop::_defaultFS
  } else {
    $_defaultFS = $defaultFS
  }
  if $jar_enable and !$_defaultFS {
    warn('Hadoop defaultFS or defaultFS parameter needed, when remote copied jar enabled')
  }

  if $historyserver_hostname {
    $hs_properties = {
      # must be with 'http://' to proper redirection from Hadoop with security
      'spark.yarn.historyServer.address' => "http://${historyserver_hostname}:${historyserver_port}",
    }
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
        'spark.history.kerberos.keytab' => '/etc/security/keytab/spark.service.keytab',
        'spark.history.kerberos.principal' => "spark/${::fqdn}@${realm}",
      }
    } else {
      $security_properties = {}
    }
  } else {
    $security_properties = {}
  }

  $_properties = merge($hs_properties, $hs_daemon_properties, $security_properties, $properties)
}
