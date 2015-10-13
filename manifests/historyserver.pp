# == Class spark::historyserver
#
# Apache Spark History Server.
#
class spark::historyserver {
  include ::spark::historyserver::install
  include ::spark::historyserver::config
  include ::spark::historyserver::service

  Class['spark::historyserver::install'] ->
  Class['spark::historyserver::config'] ~>
  Class['spark::historyserver::service'] ->
  Class['spark::historyserver']
}
