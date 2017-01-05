module Puppet::Parser::Functions
  newfunction(:github_release, :type => :rvalue, :doc => <<-EOS
Fetch a download URL based on Github release informations.

Expects a hash with the following keys:

* author: Github Author 
* repository: Github repository
* release: Release to download (defaults to "latest")
* asset: Look for an asset of the release instead of a zip- or tarball
         (defaults to true)
* use_zip: Use a zip- instead of a tarball (defaults to false)
* asset_filepattern: A regular expression to search in the asset filenames
                     (defaults to .* (everything)) 
* asset_contenttype: A regular expression to match against the content types
                     in the assets (defaults to .* (everything))
* asset_fallback: If an asset can not be found, use a zip- or tarball instead
                  If this is false, an error is raised instead. (defaults to
                  true)
* is_tag: The release specified is the name of a tag, not a release (defaults
            to false)
* use_auth: Use authenticated requests, for example to use a bigger rate limit
* username: GitHub Username 
* password: GitHub password or Authentication token
  EOS
  ) do |args|

    # Sanity check

    raise(
        Puppet::ParseError,
        'github_release(): Wrong number of arguments'
    ) unless args.size == 1

    # Convert hash keys to symbols

    args[0] = args[0].inject({}) {
        |memo, (k, v)| memo[k.to_sym] = v; memo
    }

    raise(
        Puppet::ParseError,
        'github_release(): No author given'
    ) unless args[0].has_key? :author

    raise(
        Puppet::ParseError,
        'github_release(): No repository given'
    ) unless args[0].has_key? :repository

    debug('Setting defaults')

    arguments = {
        :release => 'latest',
        :use_zip => false,
        :asset_filepattern => '.*',
        :asset_contenttype => '.*',
        :asset_fallback => true,
        :is_tag => false,
        :use_auth => false,
        :username => '',
        :password => ''
    }.merge(args[0])

    filepattern_regexp = Regexp.new(
        arguments[:asset_filepattern],
        Regexp::IGNORECASE
    )

    contenttype_regexp = Regexp.new(
        arguments[:asset_contenttype],
        Regexp::IGNORECASE
    )

    # Build up Github URL

    tag_part = ''

    if arguments[:is_tag]
      tag_part = 'tags/'
    end

    url = sprintf(
        '%s/%s/%s/releases/%s%s',
        'https://api.github.com/repos',
        arguments[:author],
        arguments[:repository],
        tag_part,
        arguments[:release]
    )

    debug(
        sprintf(
            'Loading release information from %s',
            url
        )
    )

    # Download JSON release info from Github

    download_url = ''
    release_info_json = ''

    begin

      release_info_json = function_fetch_from_url(
          [
              {
                  :url => url,
                  :use_auth => arguments[:use_auth],
                  :username => arguments[:username],
                  :password => arguments[:password]
              }
          ])

    rescue Net::HTTPServerException => e

      if e.response.code == '404'
        # This repository has no releases

        if arguments[:asset] and not arguments[:asset_fallback]
          raise(
              Puppet::ParseError,
              'Can not find a valid download URL for the release.'
          )
        end

        # Build the zip/tarball URL yourself

        warning('No release information found. Building URL myself.')

        tag = arguments[:release]

        if tag == 'latest'
          # Rework "latest" to "master"
          tag = 'master'
        end

        suffix = '.tar.gz'

        if arguments[:use_zip]
          suffix = '.zip'
        end

        download_url = sprintf(
            '%s/%s/%s/archive/%s%s',
            'https://github.com',
            arguments[:author],
            arguments[:repository],
            tag,
            suffix
        )
      else
        raise e
      end

    end

    if download_url == ''
      # Read in release info from JSON file

      debug('Parsing release info')

      release_info = PSON::load(release_info_json)

      if arguments[:asset]
        debug('Checking assets')
        release_info['assets'].each do |asset|
          debug(sprintf('Checking asset %s', asset['name']))
          if download_url == ''
            if filepattern_regexp.match(asset['name']) and
                contenttype_regexp.match(asset['content_type']) do
                  download_url = asset['browser_download_url']
                end
            end
          end
        end
      end

      if !arguments[:asset] or
          (download_url == '' and arguments[:asset_fallback])
        if arguments[:use_zip]
          debug('Setting Zipball URL')
          download_url = release_info['zipball_url']
        else
          debug('Setting Tarball URL')
          download_url = release_info['tarball_url']
        end
        unless download_url == ''
          download_url = function_fetch_from_url(
              [
                  {
                      :url => download_url,
                      :use_auth => arguments[:use_auth],
                      :username => arguments[:username],
                      :password => arguments[:password],
                      :ignore_redirect => true
                  }
              ]
          )
        end
      end

      if download_url == ''
        raise(
            Puppet::ParseError,
            'Can not find a valid download URL for the release.'
        )
      end
    end

    debug(sprintf('Download URL is %s', download_url))

    download_url

  end
end