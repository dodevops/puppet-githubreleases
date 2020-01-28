# frozen_string_literal: true

require 'spec_helper'

describe 'download_file' do
  it 'does not raise an error' do
    is_expected.not_to run.with_params(
      'https://github.com/puppetlabs/puppet/archive/master.zip',
      '/tmp/test.zip',
    ).and_raise_error(%r{.*})
  end

  it 'raises an error on an invalid URL' do
    is_expected.to run.with_params(
      'https://notmtiemtie.öäöä',
      '/tmp/nothing',
    ).and_raise_error(%r{URI must be ascii only})
  end

  it 'raises an error on a not existing URL' do
    is_expected.to run.with_params(
      'https://github.com/nothingexistsherehopefully',
      '/tmp/nothing',
    ).and_raise_error(%r{404 Not Found})
  end
end
