require_relative '../../../../lib/utils'
require 'open-uri'

Puppet::Type.type('githubreleases_download').provide(:githubreleases_download) do
  desc 'Default provider'

  def create
    download_url = get_download_url(@resource[:author], @resource[:repository], @resource)
    download = open(download_url)
    IO.copy_stream(download, @resource[:target])
  end

  def destroy
    File.unlink @resource[:target]
  end

  def exists?
    File.exist? @resource[:target]
  end
end
