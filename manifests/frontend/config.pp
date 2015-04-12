# == Class spark::frontend::config
#
# This class is called from spark::frontend.
#
class spark::frontend::config {
  include hadoop::common::config
  include hadoop::common::hdfs::config
  include hadoop::common::yarn::config
  include spark::common::config

  $hadoop_confdir = $hadoop::confdir
  file {'/etc/profile.d/hadoop-spark.sh':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('spark/profile.sh.erb')
  }
  file {'/etc/profile.d/hadoop-spark.csh':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('spark/profile.csh.erb')
  }
}
