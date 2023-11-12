require_relative '../../../../lib/utils'
require 'open-uri'

Puppet::Type.type('githubreleases_download').provide(:githubreleases_download) do
  desc 'Default provider'

  def create
    download_url = get_download_url(@resource[:author], @resource[:repository], @resource)
    uri = URI.parse(download_url)

    # Follow redirects
    response = Net::HTTP.get_response(uri)

    while [301, 302].include?(response.code.to_i)
      uri = URI.parse(response['location'])
      response = Net::HTTP.get_response(uri)
    end

    # Download the file
    open(@resource[:target], 'wb') do |file|
      file << response.body
    end
  end

  def destroy
    File.unlink @resource[:target]
  end

  def exists?
    File.exist? @resource[:target]
  end
end
