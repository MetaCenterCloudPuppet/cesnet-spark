# == Class spark::common::postinstall
#
# Preparation steps after installation. It switches spark-conf alternative, if enabled.
#
class spark::common::postinstall {
  ::hadoop_lib::postinstall{ 'spark':
    alternatives => $::spark::alternatives,
  }
}
