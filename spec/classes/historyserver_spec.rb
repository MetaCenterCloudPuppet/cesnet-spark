require 'spec_helper'

describe 'spark::historyserver::config', :type => 'class' do
  on_supported_os.each do |os,facts|
    path = test_config_dir(os)

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
  let(:pre_condition) { 'include spark::params include spark' }
  on_supported_os.each do |os,facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it { should contain_class('spark::historyserver') }
      it { should contain_class('spark::historyserver::install') }
      it { should contain_class('spark::historyserver::config') }
      it { should contain_class('spark::historyserver::service') }
    end
  end
end
