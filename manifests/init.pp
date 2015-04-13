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
# ####`history_hostname` undef
#
# TODO: not implemented yet Spark History server hostname.
#
# ####`jar_enable` false
#
# Configure Apache Spark to search Spark jar file in *$hdfs\_hostname/user/spark/share/lib/spark-assembly.jar*. The jar needs to be copied to HDFS manually, or also manually updated after each Spark SW update.
#
# ####`yarn_enable` true
#
# Enable YARN mode by default. This requires configured Hadoop using CESNET Hadoop puppet module.
#
class spark (
  $alternatives = $params::alternatives,
  $hdfs_hostname = undef,
  $history_hostname = undef,
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
}
