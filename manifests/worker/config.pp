# == Class spark::worker::config
#
# This class is called from spark::worker
#
class spark::worker::config {
  include ::stdlib
  contain spark::common::config
}
