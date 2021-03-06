# == Class spark::common::config
#
# Common configuration for Apache Spark.
#
class spark::common::config {
  include ::stdlib
  if $spark::yarn_enable or $hadoop::hdfs_hostname {
    contain hadoop::common::config
    contain hadoop::common::hdfs::config
  }

  ensure_packages($spark::packages['common'])

  $master_hostname = $spark::master_hostname
  $master_port = $spark::master_port
  $master_ui_port = $spark::master_ui_port
  $worker_port = $spark::worker_port
  $worker_ui_port = $spark::worker_ui_port

  file{"${spark::confdir}/spark-defaults.conf":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('spark/spark-defaults.conf.erb'),
    require => Package[$spark::packages['common']],
  }

  $confdir = $spark::confdir
  $environment = $spark::environment
  augeas{"${confdir}/spark-env.sh":
    lens    => 'Shellvars.lns',
    incl    => "${confdir}/spark-env.sh",
    changes => template('spark/spark-env.sh.augeas.erb'),
  }

}
