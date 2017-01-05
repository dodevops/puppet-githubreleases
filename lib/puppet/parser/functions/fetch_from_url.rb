module Puppet::Parser::Functions
  newfunction(:fetch_from_url, :type => :rvalue, :doc => <<-EOS
Fetch something from the given URL, handle redirects and errors.

Expects one has argument with the following keys:

* url: URL to fetch
* limit: Limit of fetches (for redirects, defaults to 10)
* use_auth: Use Basic Auth
* username: Username for auth
* password: Password for auth
* ignore_redirect: Ignore redirect, just return the new location 
                   (defaults to false)
  EOS
  ) do |args|

    raise(
        Puppet::ParseError,
        'Not enough arguments'
    ) unless args.size == 1

    arguments = {
        :limit => 10,
        :use_auth => false,
        :ignore_redirect => false
    }.merge(args[0])

    uri_str = arguments[:url]
    limit = arguments[:limit]

    raise(
        ArgumentError,
        'Too many HTTP redirects downloading release info'
    ) if limit == 0

    uri = URI(uri_str)

    request = Net::HTTP::Get.new(uri.path)

    if arguments[:use_auth]
      debug(sprintf('Authenticating as %s', arguments[:username]))
      request.basic_auth(
          arguments[:username],
          arguments[:password]
      )
    end

    debug(sprintf('Fetching %s. Limit: %d', uri_str, limit))

    response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) { |http|
      http.request(request)
    }

    case response
      when Net::HTTPRedirection then
        debug('Redirecting...')

        if arguments[:ignore_redirect]
          response['location']
        else
          arguments[:url] = response['location']
          arguments[:limit] -= 1
          function_fetch_from_url([arguments])
        end
      when Net::HTTPSuccess
        debug('Success. Returning body.')
        response.body
      else
        raise(
            ArgumentError,
            sprintf(
                'Can not download release info: %s',
                response.value
            )
        )
    end

  end

end