# == Class spark::frontend::config
#
# This class is called from spark::frontend.
#
class spark::frontend::config {
  include ::spark::common::config
  if $spark::hive_enable {
    file { "${spark::confdir}/hive-site.xml":
      ensure => link,
      target => $::spark::hive_configfile,
    }
  }
  if $spark::yarn_enable {
    include ::hadoop::common::yarn::config
  }

  if $spark::hdfs_hostname or $spark::yarn_enable {
    $hadoop_confdir = $hadoop::confdir
    file {'/etc/profile.d/hadoop-spark.sh':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('spark/profile.sh.erb'),
    }
    file {'/etc/profile.d/hadoop-spark.csh':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('spark/profile.csh.erb'),
    }
  } else {
    file {'/etc/profile.d/hadoop-spark.sh':
      ensure => 'removed',
    }
    file {'/etc/profile.d/hadoop-spark.csh':
      ensure => 'removed',
    }
  }
}
