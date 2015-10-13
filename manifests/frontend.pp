# == Class spark::frontend
#
# Apache Spark Client.
#
class spark::frontend {
  include ::spark::frontend::install
  include ::spark::frontend::config

  Class['spark::frontend::install'] ->
  Class['spark::frontend::config'] ->
  Class['spark::frontend']
}
