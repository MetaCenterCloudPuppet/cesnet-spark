$realm = ''

class{'hadoop':
  realm => $realm,
}

class{'spark':
  realm => $realm,
}
