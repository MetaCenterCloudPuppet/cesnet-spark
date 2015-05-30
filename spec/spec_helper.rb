require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

$test_os=[{
    'osfamily' => 'Debian',
    'operatingsystem' => 'Debian',
    'operatingsystemrelease' => ['7']
  }, {
    'osfamily' => 'Debian',
    'operatingsystem' => 'Ubuntu',
    'operatingsystemrelease' => ['14.04']
  }]

$test_config_dir={
  'Debian' => '/etc/spark/conf',
  'Fedora' => '/etc/spark',
  'Ubuntu' => '/etc/spark/conf',
}
