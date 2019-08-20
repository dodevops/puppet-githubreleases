require 'spec_helper'

describe 'githubreleases::download' do

  let(:title) { 'test' }

  use_auth = false
  username = ''
  password = ''

  if ENV['GITHUB_USE_AUTH']
    use_auth = true
    username = ENV['GITHUB_USERNAME']
    password = ENV['GITHUB_PASSWORD']
  end

  let(:params) {
    {
        :author => 'dodevops',
        :repository => 'puppet-githubreleases',
        :target => '/tmp/test',
        :use_auth => use_auth,
        :username => username,
        :password => password
    }
  }

  it { is_expected.to contain_remote_file('fetch./tmp/test') }

end
