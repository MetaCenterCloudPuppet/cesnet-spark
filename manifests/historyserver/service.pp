# == Class spark::historyserver::service
#
# Launch Apache Spark History Server service.
#
class spark::historyserver::service {
  service { $spark::daemons['historyserver']:
    ensure    => 'running',
    enable    => true,
    subscribe => File['spark-defaults.conf'],
  }
}
