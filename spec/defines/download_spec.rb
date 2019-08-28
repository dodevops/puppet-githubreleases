# frozen_string_literal: true

require 'spec_helper'

describe 'githubreleases::download' do
  use_auth = false
  use_oauth = false
  username = ''
  password = ''

  if ENV['GITHUB_USE_AUTH']
    use_auth = true
    username = ENV['GITHUB_USERNAME']
    password = ENV['GITHUB_PASSWORD']
  end

  use_oauth = true if ENV['GITHUB_USE_OAUTH']

  let(:title) { 'test' }

  let(:params) do
    {
      author: 'dodevops',
      repository: 'puppet-githubreleases',
      target: '/tmp/test',
      use_auth: use_auth,
      use_oauth: use_oauth,
      username: username,
      password: password,
    }
  end

  it { is_expected.to contain_remote_file('fetch./tmp/test') }

  context 'with specific release' do
    let(:params) do
      {
        author: 'Graylog2',
        repository: 'collector-sidecar',
        release: '0.0.2',
        is_tag: true,
        target: '/tmp/test',
        use_auth: use_auth,
        use_oauth: use_oauth,
        username: username,
        password: password,
      }
    end

    it {
      is_expected.to contain_remote_file('fetch./tmp/test').with_source(
        'https://api.github.com/repos/Graylog2/collector-sidecar/tarball/0.0.2',
      )
    }
  end
end
