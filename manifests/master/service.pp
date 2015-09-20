# == Class spark::master::service
#
# Launch Apache Spark Master service.
#
class spark::master::service {
  service { $spark::daemons['master']:
    ensure    => 'running',
    enable    => true,
    subscribe => File['spark-defaults.conf'],
  }
}
