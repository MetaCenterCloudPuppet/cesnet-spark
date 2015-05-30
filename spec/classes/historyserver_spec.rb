require 'spec_helper'

describe 'spark::historyserver::config', :type => 'class' do
  $test_os.each do |facts|
    os = facts['operatingsystem']
    path = $test_config_dir[os]

    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it { should contain_file(path + '/spark-defaults.conf') }
    end
  end
end

describe 'spark::historyserver', :type => 'class' do
  $test_os.each do |facts|
    os = facts['operatingsystem']

    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it { should contain_class('spark::historyserver::install') }
      it { should contain_class('spark::historyserver::config') }
      it { should contain_class('spark::historyserver::service') }
    end
  end
end
