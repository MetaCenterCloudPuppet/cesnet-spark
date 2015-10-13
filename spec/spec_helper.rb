require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

def test_config_dir(os)
    case
    when os.match(/centos|redhat|scientific/)
        return '/etc/spark/conf'
    when os.match(/debian|ubuntu/)
        return '/etc/spark/conf'
    when os.match(/fedora/)
        return '/etc/spark'
    end
end
