require 'spec_helper'
require 'fileutils'

describe 'file_exists' do

  it 'should return false for a non-existent file' do
    is_expected.to run.with_params(
        'non_existing_file'
    ).and_return(false)
  end

  it 'should return true for an existing file' do
    FileUtils.touch('existing_file')
    is_expected.to run.with_params(
        'existing_file'
    ).and_return(true)
    FileUtils.rm('existing_file')
  end

end