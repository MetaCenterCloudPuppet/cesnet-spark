require 'spec_helper'

describe 'spark::frontend::config', :type => 'class' do
  on_supported_os.each do |os,facts|
    path = test_config_dir(os)

    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it { should contain_file(path + '/spark-defaults.conf') }
      it { should contain_file(path + '/hive-site.xml').with_ensure('link') }
      it { should contain_file('/etc/profile.d/hadoop-spark.sh') }
    end
  end
end

describe 'spark::frontend', :type => 'class' do
  on_supported_os.each do |os,facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it { should contain_class('spark::frontend::install') }
      it { should contain_class('spark::frontend::config') }
    end
  end
end
