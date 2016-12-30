require 'spec_helper'

describe 'githubreleases::download' do

  let(:title) { 'test' }
  let(:params) {
    {
        :author => 'puppetlabs',
        :repository => 'puppet',
        :target => '/tmp/test'
    }
  }

  it { is_expected.to contain_remote_file('fetch./tmp/test') }

end