# == Class spark::worker
#
# Apache Spark Worker Node.
#
class spark::worker {
  include ::spark::worker::install
  include ::spark::worker::config
  include ::spark::worker::service

  Class['spark::worker::install'] ->
  Class['spark::worker::config'] ~>
  Class['spark::worker::service'] ->
  Class['spark::worker']
}
