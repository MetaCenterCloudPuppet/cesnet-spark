# == Class spark::historyserver::config
#
# This class is called from spark::historyserver.
#
class spark::historyserver::config {
  include ::stdlib
  contain spark::common::config

  validate_string($spark::hdfs_hostname)
  validate_string($spark::historyserver_hostname)
  if $spark::hdfs_hostname == undef {
    fail('hdfs_hostname required in cluster with Spark History Server')
  }
  if $spark::historyserver_hostname == undef {
    fail('historyserver_hostname required in cluster with Spark History Server')
  }

  $keytab = $spark::keytab_historyserver
  if $spark::realm and $spark::realm != '' {
    file { $keytab:
      owner => 'spark',
      group => 'spark',
      mode  => '0400',
      alias => 'spark.service.keytab',
    }
  }
}
