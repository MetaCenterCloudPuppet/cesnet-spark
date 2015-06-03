# == Class: spark
#
# Main configure class for CESNET Apache Spark puppet module.
#
# === Parameters
#
# ####`alternatives` (see params.pp)
#
# Use alternatives to switch configuration. Use it only when supported (like with Cloudera).
#
# ####`hdfs_hostname` undef
#
# HDFS hostname or defaultFS (for example: host:8020, haName, ...).
#
# ####`historyserver_hostname` undef
#
# Spark History server hostname.
#
# ####`environment` undef
#
# Environments to set for Apache Spark. "::undef" will unset the variable.
#
# You may need to increase memory in case of big amount of jobs:
#
#     environment => {
#       'SPARK_DAEMON_MEMORY' => '4096m',
#     }
#
# #### `properties` undef
#
# Spark properties to set.
#
# ####`realm` undef
#
# Kerberos realm. Non-empty string enables security.
#
# ####`jar_enable` false
#
# Configure Apache Spark to search Spark jar file in *$hdfs\_hostname/user/spark/share/lib/spark-assembly.jar*. The jar needs to be copied to HDFS manually after installation, and also manually updated after each Spark SW update:
#
#     hdfs dfs -put /usr/lib/spark/spark-assembly.jar /user/spark/share/lib/spark-assembly.jar
#
# ####`yarn_enable` true
#
# Enable YARN mode by default. This requires configured Hadoop using CESNET Hadoop puppet module.
#
class spark (
  $alternatives = $params::alternatives,
  $hdfs_hostname = undef,
  $historyserver_hostname = undef,
  $environment = undef,
  $properties = undef,
  $realm = undef,
  $jar_enable = false,
  $yarn_enable = true,
) inherits ::spark::params {
  include stdlib

  if $alternatives {
    validate_string($alternatives)
  }
  validate_bool($jar_enable)
  if $jar_enable and !$hdfs_hostname {
    warn('$hdfs_hostname parameter needed, when remote copied jar enabled')
  }

  if $historyserver_hostname {
    $hs_properties = {
      # must be with 'http://' to proper redirection from Hadoop with security
      'spark.yarn.historyServer.address' => "http://${historyserver_hostname}:18080"
    }
  }
  if $historyserver_hostname == $::fqdn {
    $hs_daemon_properties = {
      'spark.history.ui.port' => 18080,
    }
  }
  if $realm and $realm != '' {
    if $historyserver_hostname == $::fqdn {
      $security_properties = {
        'spark.history.kerberos.enabled' => true,
        'spark.history.kerberos.keytab' => '/etc/security/keytab/spark.service.keytab',
        'spark.history.kerberos.principal' => "spark/${::fqdn}@${realm}",
      }
    }
  }

  $_properties = merge($hs_properties, $hs_daemon_properties, $security_properties, $properties)
}
