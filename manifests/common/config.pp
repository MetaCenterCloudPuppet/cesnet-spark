# == Class spark::common::config
#
# Common configuration for Apache Spark.
#
class spark::common::config {
  include stdlib

  ensure_packages($spark::packages['common'])

  $hdfs_hostname = $spark::hdfs_hostname
  $jar_enable = $spark::jar_enable
  $historyserver_hostname = $spark::historyserver_hostname
  $yarn_enable = $spark::yarn_enable

  file{"${spark::confdir}/spark-defaults.conf":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('spark/spark-defaults.conf.erb'),
    alias   => 'spark-defaults.conf',
    require => Package[$spark::packages['common']],
  }

  file{"${spark::defaultdir}/spark":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('spark/env.erb'),
    alias   => 'spark-env',
    require => Package[$spark::packages['common']],
  }

  $confdir = $spark::confdir
  $environments = $spark::environments
  if $environments {
    augeas{"${confdir}/spark-env.sh":
      lens    => 'Shellvars.lns',
      incl    => "${confdir}/spark-env.sh",
      changes => template('spark/spark-env.sh.augeas.erb'),
    }
  }

}
