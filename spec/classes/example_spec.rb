require 'spec_helper'

describe 'spark' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "spark class without any parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('spark::params') }
          it { is_expected.to contain_class('spark::install').that_comes_before('spark::config') }
          it { is_expected.to contain_class('spark::config') }
          it { is_expected.to contain_class('spark::service').that_subscribes_to('spark::config') }

          it { is_expected.to contain_service('spark') }
          it { is_expected.to contain_package('spark').with_ensure('present') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'spark class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('spark') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
