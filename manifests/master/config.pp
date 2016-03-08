# == Class spark::master::config
#
# This class is called from spark::master.
#
class spark::master::config {
  include ::stdlib
  contain spark::common::config

  validate_string($spark::master_hostname)
}
