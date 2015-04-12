# == Class spark::common::config
#
# Common configuration for Apache Spark.
#
class spark::common::config {
  $hdfs_hostname = $spark::hdfs_hostname
  $jar_enable = $spark::jar_enable
  $history_hostname = $spark::history_hostname
  file{"${spark::confdir}/spark-defaults.conf":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('spark/spark-defaults.conf.erb'),
    alias   => 'spark-defaults.conf',
  }
}
