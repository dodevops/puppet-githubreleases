# frozen_string_literal: true

require_relative 'utils'

# Fetch a download URL based on Github release informations.
Puppet::Functions.create_function(:github_release) do
  # Fetch a download URL based on Github release informations.
  # @param author Github Author
  # @param repository Github repository
  # @param options Additional options
  # @option options [String] :release Release to use
  # @option options [Boolean] :asset Look for an asset of the release instead of a zip- or tarball
  # @option options [Boolean] :use_zip Use a zip- instead of a tarball
  # @option options [String] :asset_filepattern A regular expression to search in the asset filenames
  # @option options [String] :asset_contenttype A regular expression to match against the content types in the assets
  # @option options [Boolean] :asset_fallback If an asset can not be found, use a zip- or tarball instead.
  #                                           If this is false, an error is raised instead.
  # @option options [String] :is_tag The release specified is the name of a tag, not a release
  # @option options [String] :use_auth Use authenticated requests, for example to use a bigger rate limit
  # @option options [String] :use_oauth Use OAuth when using authenticated requests
  #                                     (then username/password is used for client id/secret)
  # @option options [String] :username GitHub Username
  # @option options [String] :password GitHub password or Authentication token
  # @return [String] The download URL for the requested assset
  dispatch :default do
    param 'String', :author
    param 'String', :repository
    optional_param 'Hash', :options
  end

  def default(
    author,
    repository,
    options
  )

    # Merge given options with default options
    # Symbolize the keys of the given options as we might get them via Puppet
    options = {
      release: 'latest',
      use_auth: false,
      use_oauth: false,
      username: '',
      password: '',
      asset: false,
      use_zip: false,
      asset_filepattern: '.*',
      asset_contenttype: '.*',
      asset_fallback: true,
      is_tag: false,
    }.merge(options.each_with_object({}) { |(k, v), h| h[k.to_sym] = v })

    Puppet.debug(
      Kernel.format(
        'Got options: %{author} %{repo} %{option}',
        author: author,
        repo: repository,
        option: options.to_s,
      ),
    )

    download_url = get_download_url(
      author,
      repository,
      options,
    )

    if download_url == ''
      raise(
        Puppet::ParseError,
        'Can not find a valid download URL for the release.',
      )
    end

    Puppet.debug(Kernel.format('Download URL is %{url}', url: download_url))

    download_url
  end
end
