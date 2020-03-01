# == Class spark::master::config
#
# This class is called from spark::master.
#
class spark::master::config {
  contain spark::common::config
}
