# == Class: spark::frontend::install
#
# Install Spark client packages.
#
class spark::frontend::install {
  include ::stdlib
  contain spark::common::postinstall

  ensure_packages($spark::packages['frontend'])
  Package[$spark::packages['frontend']] -> Class['spark::common::postinstall']
}
