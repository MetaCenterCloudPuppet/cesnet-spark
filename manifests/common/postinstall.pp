# == Class spark::common::postinstall
#
# Preparation steps after installation. It switches spark-conf alternative, if enabled.
#
class spark::common::postinstall {
  $confname = $spark::alternatives
  $path = '/sbin:/usr/sbin:/bin:/usr/bin'

  if $confname {
    exec { 'spark-copy-config':
      command => "cp -a ${spark::confdir}/ /etc/spark/conf.${confname}",
      path    => $path,
      creates => "/etc/spark/conf.${confname}",
    }
    ->
    alternative_entry{"/etc/spark/conf.${confname}":
      altlink  => '/etc/spark/conf',
      altname  => 'spark-conf',
      priority => 50,
    }
    ->
    alternatives{'spark-conf':
      path => "/etc/spark/conf.${confname}",
    }
  }
}
