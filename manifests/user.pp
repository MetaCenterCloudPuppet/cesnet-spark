# == Class spark::user
#
# Create spark system user. The spark user is required on the all HDFS namenodes to autorization work properly and we don't need to install spark just for the user.
#
# It is better to handle creating the user by the packages, so we recommend dependecny on installation classes or Spark packages.
#
class spark::user {
  group { 'spark':
    ensure => present,
    system => true,
  }
  case "${::osfamily}-${::operatingsystem}" {
    /RedHat-Fedora/: {
      user { 'spark':
        ensure     => present,
        system     => true,
        comment    => 'Apache Spark',
        gid        => 'spark',
        home       => '/var/lib/spark',
        managehome => true,
        password   => '!!',
        shell      => '/sbin/nologin',
      }
    }
    /Debian|RedHat/: {
      user { 'spark':
        ensure     => present,
        system     => true,
        comment    => 'Spark User',
        gid        => 'spark',
        home       => '/var/lib/spark',
        managehome => true,
        password   => '!!',
        shell      => '/bin/false',
      }
    }
    default: {
      notice("${::operatingsystem} (${::osfamily}) not supported")
    }
  }
  Group['spark'] -> User['spark']
}
