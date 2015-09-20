$realm = ''

class{'hadoop':
  realm => $realm,
}

class{'spark':
  hdfs_hostname          => $::fqdn,
  historyserver_hostname => $::fqdn,
  realm                  => $realm,
}
