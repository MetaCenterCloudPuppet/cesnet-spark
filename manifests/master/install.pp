# == Class: spark::master::install
#
# Install Spark Master packages.
#
class spark::master::install {
  include ::stdlib
  contain spark::common::postinstall

  $path = '/sbin:/usr/sbin:/bin:/usr/bin'

  ensure_packages($spark::packages['master'])
  Package[$spark::packages['master']] -> Class['spark::common::postinstall']
}
