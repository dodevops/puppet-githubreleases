require 'spec_helper'

# Check basic feature

describe 'After puppet-githubreleases' do
  describe file('/tmp/release.latest.head.tar.gz') do
    it { is_expected.to exist }
    it { is_expected.to be_file }
  end

  # Check release tarball feature

  describe file('/tmp/release.0.0.2.head.tar.gz') do
    it { is_expected.to exist }
    it { is_expected.to be_file }
    its(:md5sum) { is_expected.to eq 'c76c61814a4845e16ad200cd0dbb0492' }
  end

  # Check release zipball feature

  describe file('/tmp/release.0.0.2.head.zip') do
    it { is_expected.to exist }
    it { is_expected.to be_file }
    its(:md5sum) { is_expected.to eq 'ca899e062eed1c0c5e8ee5ad732a5303' }
  end

  # Check asset content type filtering feature

  describe file('/tmp/release.0.0.2.asset.debian') do
    it { is_expected.to exist }
    it { is_expected.to be_file }
    its(:md5sum) { is_expected.to eq '5765d145e422318c0d25e19e6ec82be0' }
  end

  # Check asset namefiltering feature

  describe file('/tmp/release.0.0.2.asset.exe') do
    it { is_expected.to exist }
    it { is_expected.to be_file }
    its(:md5sum) { is_expected.to eq '53b76eb603eebb7572172a89248ac3fe' }
  end

  # Check Hiera support

  describe file('/tmp/release.latest.head.fromhiera.tar.gz') do
    it { is_expected.to exist }
    it { is_expected.to be_file }
  end
end
