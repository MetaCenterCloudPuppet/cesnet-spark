$realm = ''

class{'hadoop':
  realm => $realm,
}

class { 'spark':
  hdfs_hostname          => $facts['fqdn'],
  historyserver_hostname => $facts['fqdn'],
  realm                  => $realm,
}
