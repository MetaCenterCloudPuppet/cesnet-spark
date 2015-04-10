# == Class: spark
#
# Full description of class spark here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class spark (
  $package_name = $::spark::params::package_name,
  $service_name = $::spark::params::service_name,
) inherits ::spark::params {

  # validate parameters here

  class { '::spark::install': } ->
  class { '::spark::config': } ~>
  class { '::spark::service': } ->
  Class['::spark']
}
