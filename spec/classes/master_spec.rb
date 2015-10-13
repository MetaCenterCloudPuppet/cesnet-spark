require 'spec_helper'

describe 'spark::master::config', :type => 'class' do
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

describe 'spark::master', :type => 'class' do
  on_supported_os.each do |os,facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it { should contain_class('spark::master::install') }
      it { should contain_class('spark::master::config') }
      it { should contain_class('spark::master::service') }
    end
  end
end
