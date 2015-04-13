# == Class: spark::historyserver::install
#
# Install Spark History Server packages.
#
class spark::historyserver::install {
  include stdlib
  contain spark::common::postinstall

  ensure_packages($spark::packages['historyserver'])
  Package[$spark::packages['historyserver']] -> Class['spark::common::postinstall']
}
