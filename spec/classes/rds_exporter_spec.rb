require 'spec_helper'

describe 'prometheus::rds_exporter' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'with version specified' do
        let(:params) do
          {
            version: '0.6.0',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url'
          }
        end

        describe 'with specific params' do
          it { is_expected.to contain_archive('/tmp/rds_exporter-0.6.0.tar.gz') }
          it { is_expected.to contain_class('prometheus') }
          it { is_expected.to contain_group('rds-exporter') }
          it { is_expected.to contain_user('rds-exporter') }
          it { is_expected.to contain_prometheus__daemon('rds_exporter') }
          it { is_expected.to contain_service('rds_exporter') }
        end
        describe 'compile manifest' do
          it { is_expected.to compile.with_all_deps }
        end

        describe 'install correct binary' do
          it { is_expected.to contain_file('/usr/local/bin/rds_exporter').with('target' => '/opt/rds_exporter-0.6.0.linux-amd64/rds_exporter') }
        end
      end

      context 'with instances specified' do
        let(:params) do
          {
            'instances' => [
              {
                'region'    => 'us-east-1',
                'instance'  => 'rds-mysql57'
              },
              {
                'region'    => 'us-east-2',
                'instance'  => 'rds-mysql58'
              }
            ]
          }
        end

        describe 'has config file with expected content' do
          it { is_expected.to contain_file('/etc/rds-exporter.yaml').with_content(File.read(fixtures('files', 'rds-exporter.yaml'))) }
        end
      end
    end
  end
end
