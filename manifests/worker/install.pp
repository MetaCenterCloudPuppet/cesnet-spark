# == Class: spark::worker::install
#
# Install Spark Worker packages.
#
class spark::worker::install {
  include ::stdlib
  contain spark::common::postinstall

  ensure_packages($spark::packages['worker'])
  Package[$spark::packages['worker']] -> Class['spark::common::postinstall']
}
