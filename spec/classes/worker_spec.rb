require 'spec_helper'

describe 'spark::worker::config', :type => 'class' do
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

describe 'spark::worker', :type => 'class' do
  on_supported_os.each do |os,facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it { should contain_class('spark::worker::install') }
      it { should contain_class('spark::worker::config') }
      it { should contain_class('spark::worker::service') }
    end
  end
end
