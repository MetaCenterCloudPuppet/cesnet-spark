# == Class spark::service
#
# This class is meant to be called from spark.
# It ensure the service is running.
#
class spark::service {

  service { $::spark::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
