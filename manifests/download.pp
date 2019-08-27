# @summary Downloads release artifacts from Github
# @param release see githubreleases::release
# @param asset_filepattern see githubreleases:asset_filepattern
# @param asset_contenttype see githubreleases:asset_contenttype
# @param asset see githubreleases:asset
# @param asset_fallback see githubreleases:asset_fallback
# @param use_zip see githubreleases:use_zip
# @param is_tag see githubreleases:is_tag
# @param use_auth see githubreleases:use_auth
# @param target Target path to use (defaults to name of the ressource)
# @param author see githubreleases:author
# @param repository see githubreleases:repository
# @param username see githubreleases:username
# @param password see githubreleases:password
define githubreleases::download (
  String $release                    = 'latest',
  String $asset_filepattern          = '.*',
  String $asset_contenttype          = '.*',
  Boolean $asset                     = false,
  Boolean $asset_fallback            = false,
  Boolean $use_zip                   = false,
  Boolean $is_tag                    = false,
  Variant[Boolean, String] $use_auth = false,
  Optional[String] $target           = undef,
  Optional[String] $author           = undef,
  Optional[String] $repository       = undef,
  Optional[String] $username         = '',
  Optional[String] $password         = ''
) {

  include ::githubreleases

  # Set local variables

  $_author = $author ? {
    undef   => $githubreleases::author,
    default => $author
  }

  $_repository = $repository ? {
    undef   => $githubreleases::repository,
    default => $repository
  }

  $_release = $release ? {
    undef   => $githubreleases::release,
    default => $release
  }

  $_asset = $asset ? {
    undef   => $githubreleases::asset,
    default => $asset
  }

  $_use_zip = $use_zip ? {
    undef   => $githubreleases::use_zip,
    default => $use_zip
  }

  $_asset_filepattern = $asset_filepattern ? {
    undef   => $githubreleases::asset_filepattern,
    default => $asset_filepattern,
  }

  $_asset_contenttype = $asset_contenttype ? {
    undef   => $githubreleases::asset_contenttype,
    default => $asset_contenttype,
  }

  $_asset_fallback = $asset_fallback ? {
    undef   => $githubreleases::asset_fallback,
    default => $asset_fallback
  }

  $_is_tag = $is_tag ? {
    undef   => $githubreleases::is_tag,
    default => $is_tag
  }

  $_use_auth = $use_auth ? {
    undef   => $githubreleases::use_auth,
    default => $use_auth
  }

  $_username = $username ? {
    undef   => $githubreleases::username,
    default => $username
  }

  $_password = $password ? {
    undef   => $githubreleases::password,
    default => $password
  }

  $_target = $target ? {
    undef   => $name,
    default => $target
  }

  # Get source URL

  debug("Loading ${_repository}@${_release} by ${_author}")

  if ($_use_zip) {
    debug('Using ZIP')
  }

  if ($_use_auth) {
    debug("Authenticating as ${_username}")
  }

  $source_url = github_release(
    $_author,
    $_repository,
    {
      release           => $_release,
      asset             => $_asset,
      use_zip           => $_use_zip,
      asset_filepattern => $_asset_filepattern,
      asset_contenttype => $_asset_contenttype,
      asset_fallback    => $_asset_fallback,
      is_tag            => $_is_tag,
      use_auth          => $_use_auth,
      username          => $_username,
      password          => $_password,
    })

  remote_file {
    "fetch.${_target}":
      ensure  => 'present',
      path    => $_target,
      source  => $source_url,
      headers => {
        'User-Agent' => 'dodevops/puppet-githubreleases',
      },
  }

}
