# frozen_string_literal: true

def fetch_from_url(url, username, password, use_auth = false, use_oauth = false, ignore_redirect = false, limit = 10)
  if limit.zero?
    raise(
      ArgumentError,
      'Too many HTTP redirects downloading release info',
    )
  end

  uri = URI(url)

  if use_auth && use_oauth
    uri.query = Kernel.format(
      '%{query}&client_id=%{username}&client_secret=%{password}',
      query: uri.query,
      username: username,
      password: password,
    )
  end

  request = Net::HTTP::Get.new(uri.to_s)

  if use_auth && !use_oauth
    Puppet.debug(Kernel.format('Authenticating as %{username}', username: username))
    request.basic_auth(
      username,
      password,
    )
  end

  Puppet.debug(Kernel.format('Fetching %{url}. Limit: %{limit}', url: uri.to_s, limit: limit))

  Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    response = http.request(request)
    case response
    when Net::HTTPRedirection then
      Puppet.debug('Redirecting...')

      if ignore_redirect
        response['location']
      else
        fetch_from_url(response.location, username, password, use_auth, use_oauth, ignore_redirect, limit - 1)
      end
    when Net::HTTPSuccess
      Puppet.debug('Success. Returning body.')
      response.body
    when Net::HTTPNotFound
      Puppet.debug('No release found. Returning nothing')
      nil
    else
      raise(
        ArgumentError,
        Kernel.format(
          'Can not download release info: %{body}',
          body: response.body,
        ),
      )
    end
  end
end

# Fetch the release info hash from Github
# @param [String] author Github Author
# @param [String] repository Github repository
# @param [Hash] options Additional options
def get_release_info(author, repository, options)
  url = Kernel.format(
    'https://api.github.com/repos/%{author}/%{repository}/releases/%{tag}%{release}',
    author: author,
    repository: repository,
    tag: (options[:is_tag]) ? 'tags/' : '',
    release: options[:release],
  )

  release_info_json = fetch_from_url(
    url,
    options[:username],
    options[:password],
    options[:use_auth],
    options[:use_oauth],
  )

  return nil unless release_info_json

  # Read in release info from JSON file

  Puppet.debug('Parsing release info')

  # noinspection RubyResolve
  JSON.parse(release_info_json)
end

# Fetch the download URL to the right asset from the release info
# @param [Object] release_info GitHub Release Info hash
# @param [String] filepattern A regular expression to search in the asset filenames
# @param [String] contenttype A regular expression to match against the content types in the assets
# @return [String] The download URL to the asset or an empty string
def get_asset(release_info, filepattern, contenttype)
  filepattern_regexp = Regexp.new(
    filepattern,
    Regexp::IGNORECASE,
  )

  contenttype_regexp = Regexp.new(
    contenttype,
    Regexp::IGNORECASE,
  )
  Puppet.debug('Checking assets')
  release_info['assets'].each do |release_asset|
    Puppet.debug(
      Kernel.format(
        'Checking asset %{name} for RegExp %{regexp}',
        name: release_asset['name'],
        regexp: filepattern_regexp.to_s,
      ),
    )
    Puppet.debug(
      Kernel.format(
        'Checking content type %{content_type} for RegExp %{regexp}',
        content_type: release_asset['content_type'],
        regexp: contenttype_regexp.to_s,
      ),
    )
    next unless filepattern_regexp.match(
      release_asset['name'],
    ) && contenttype_regexp.match(release_asset['content_type'])

    Puppet.debug(
      Kernel.format(
        'Both are matching. Returning URL %{url}',
        url: release_asset['browser_download_url'],
      ),
    )

    return release_asset['browser_download_url'] if release_asset.key?('browser_download_url')
  end

  ''
end

# Build the zip/tarball URL if no release info can be fetched
# @param [String] author Github Author
# @param [String] repository Github repository
# @param [Hash] options Additional options
def build_asset_url(author, repository, options)
  Puppet.warning('Building URL myself.')

  tag = options[:release]

  if tag == 'latest'
    # Rework "latest" to "master"
    tag = 'master'
  end

  suffix = (options[:use_zip]) ? '.zip' : '.tar.gz'

  Kernel.format(
    'https://github.com/%{author}/%{repository}/archive/%{tag}%{suffix}',
    author: author,
    repository: repository,
    tag: tag,
    suffix: suffix,
  )
end

# Return the archive URL correctly
# @param [Object] release_info GitHub Release Info hash
# @param [Boolean] use_zip Use a zip- instead of a tarball
# @return [String] The archive URL or an empty string
def get_archive_from_release_info(release_info, use_zip)
  use_zip ? release_info['zipball_url'] : release_info['tarball_url']
end

# Calculate the download URL using various methods
# @param author Github Author
# @param repository Github repository
# @param options Hash with additional options
# @return [String] the download URL or an empty string
def get_download_url(author, repository, options)
  release_info = get_release_info(author, repository, options)

  if options[:asset] && release_info
    download_url = get_asset(release_info, options[:asset_filepattern], options[:asset_contenttype])
    return download_url unless download_url == ''

    get_archive_from_release_info(release_info, options[:use_zip])
  elsif release_info
    get_archive_from_release_info(release_info, options[:use_zip])
  elsif options[:asset_fallback] || !options[:asset]
    build_asset_url(
      author,
      repository,
      options,
    )
  else
    raise ArgumentError("Can't find download url for given criteria")
  end
end
