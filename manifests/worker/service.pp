# == Class spark::worker::service
#
# Launch Apache Spark Worker service.
#
class spark::worker::service {
  service { $spark::daemons['worker']:
    ensure    => 'running',
    enable    => true,
    subscribe => File['spark-defaults.conf'],
  }
}
