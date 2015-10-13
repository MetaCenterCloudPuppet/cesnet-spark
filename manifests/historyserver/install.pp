# == Class: spark::historyserver::install
#
# Install Spark History Server packages.
#
class spark::historyserver::install {
  include ::stdlib
  contain spark::common::postinstall

  $path = '/sbin:/usr/sbin:/bin:/usr/bin'

  case $::osfamily {
    # Debian really fucked up design around postinstallation scripts
    'debian': {
      exec {'debian-fuckup':
        command => 'touch /etc/init.d/spark-history-server && chmod +x /etc/init.d/spark-history-server',
        path    => $path,
        creates => '/etc/init.d/spark-history-server',
      }
      ->
      package{$spark::packages['historyserver']:
        ensure => installed,
      }
      ->
      exec{'debian-restore-fuckup':
        command => 'mv -v /etc/init.d/spark-history-server.dpkg-dist /etc/init.d/spark-history-server',
        path    => $path,
        onlyif  => 'test -f /etc/init.d/spark-history-server.dpkg-dist',
      }
    }
    default: {
      ensure_packages($spark::packages['historyserver'])
    }
  }
  Package[$spark::packages['historyserver']] -> Class['spark::common::postinstall']
}
