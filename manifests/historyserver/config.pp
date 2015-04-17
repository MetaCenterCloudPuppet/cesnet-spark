# == Class spark::historyserver::config
#
# This class is called from spark::historyserver.
#
class spark::historyserver::config {
  include stdlib
  contain hadoop::common::config
  contain hadoop::common::hdfs::config
  contain spark::common::config

  validate_string($spark::historyserver_hostname)

  $keytab = $spark::keytab_historyserver
  if $spark::realm {
    file { $keytab:
      owner => 'spark',
      group => 'spark',
      mode  => '0400',
      alias => 'spark.service.keytab',
    }
  }
}
