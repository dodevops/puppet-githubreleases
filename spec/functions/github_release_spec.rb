require 'spec_helper'

describe 'github_release' do

  use_auth = false
  username = ''
  password = ''

  if ENV['GITHUB_USE_AUTH']
    use_auth = true
    username = ENV['GITHUB_USERNAME']
    password = ENV['GITHUB_PASSWORD']
  end

  it 'should raise an error for a missing author' do
    is_expected.to run.with_params(
        {
            :repository => 'something',
            :use_auth => use_auth,
            :username => username,
            :password => password
        }
    ).and_raise_error(
        Puppet::ParseError,
        /No author given/
    )
  end

  it 'should raise an error for a missing repository' do
    is_expected.to run.with_params(
        {
            :author => 'something',
            :use_auth => use_auth,
            :username => username,
            :password => password
        }
    ).and_raise_error(
        Puppet::ParseError,
        /No repository given/
    )
  end

  it 'should give the HEAD tarball URL' do
    is_expected.to run.with_params(
        {
            :repository => 'puppet',
            :author => 'puppetlabs',
            :use_auth => use_auth,
            :username => username,
            :password => password
        }
    ).and_return(
        'https://github.com/puppetlabs/puppet/archive/master.tar.gz'
    )
  end

  it 'should give the HEAD zipball URL' do
    is_expected.to run.with_params(
        {
            :repository => 'puppet',
            :author => 'puppetlabs',
            :use_zip => true,
            :use_auth => use_auth,
            :username => username,
            :password => password
        }
    ).and_return(
        'https://github.com/puppetlabs/puppet/archive/master.zip'
    )
  end

  it 'should give the HEAD tarball URL for a repository with actual releases' do
    is_expected.to run.with_params(
        {
            :author => 'Graylog2',
            :repository => 'collector-sidecar',
            :use_auth => use_auth,
            :username => username,
            :password => password
        }
    ).and_return(
         /https:\/\/.*.github.com\/Graylog2\/collector-sidecar\/.*\.tar\.gz\//
    )
  end

  it 'should give a tarball of a specific release' do
    is_expected.to run.with_params(
        {
            :repository => 'collector-sidecar',
            :author => 'Graylog2',
            :release => '0.0.2',
            :is_tag => true,
            :use_auth => use_auth,
            :username => username,
            :password => password
        }
    ).and_return(
        /https:\/\/.*.github.com\/Graylog2\/collector-sidecar\/legacy.tar.gz/
    )
  end

  it 'should give a zipball of a specific release' do
    is_expected.to run.with_params(
        {
            :repository => 'collector-sidecar',
            :author => 'Graylog2',
            :release => '0.0.2',
            :use_zip => true,
            :is_tag => true,
            :use_auth => use_auth,
            :username => username,
            :password => password
        }
    ).and_return(
      /https:\/\/.*.github.com\/Graylog2\/collector-sidecar\/legacy.zip/
    )
  end

  it 'should give a matching content_type package' do
    is_expected.to run.with_params(
        {
            :repository => 'collector-sidecar',
            :author => 'Graylog2',
            :release => '0.0.2',
            :is_tag => true,
            :asset => true,
            :asset_contenttype => /application\/x-deb/,
            :use_auth => use_auth,
            :username => username,
            :password => password
        }
    ).and_return(
        'https://github.com/Graylog2/collector-sidecar/releases/download/0.0.2/collector-sidecar_0.0.2-1_amd64.deb'
    )
  end

  it 'should give a matching filename' do
    is_expected.to run.with_params(
        {
            :repository => 'collector-sidecar',
            :author => 'Graylog2',
            :release => '0.0.2',
            :is_tag => true,
            :asset => true,
            :asset_filepattern => /graylog_collector_sidecar_installer\.exe/,
            :use_auth => use_auth,
            :username => username,
            :password => password
        }
    ).and_return(
        'https://github.com/Graylog2/collector-sidecar/releases/download/0.0.2/graylog_collector_sidecar_installer.exe'
    )
  end

end
