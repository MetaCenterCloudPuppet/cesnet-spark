$realm = ''

class{'hadoop':
  realm => $realm,
}

class{'spark':
  historyserver_hostname => $::fqdn,
  realm                  => $realm,
}
