define githubreleases::download (
  $author            = undef,
  $repository        = undef,
  $release           = undef,
  $asset             = undef,
  $use_zip           = undef,
  $asset_filepattern = undef,
  $asset_contenttype = undef,
  $asset_fallback    = undef,
  $is_tag            = undef,
  $use_auth          = undef,
  $username          = undef,
  $password          = undef,
  $target            = undef
) {

  include githubreleases

  # Set local variables

  $_author = pick($author, $githubreleases::author)
  $_repository = pick($repository, $::githubreleases::repository)
  $_release = pick($release, $githubreleases::release)
  $_asset = pick($asset, $githubreleases::asset)
  $_use_zip = pick($use_zip, $githubreleases::use_zip)
  $_asset_filepattern = pick(
    $asset_filepattern,
    $githubreleases::asset_filepattern
  )
  $_asset_contenttype = pick(
    $asset_contenttype,
    $githubreleases::asset_contenttype
  )
  $_asset_fallback = pick(
    $asset_fallback,
    $githubreleases::asset_fallback
  )
  $_is_tag = pick(
    $is_tag,
    $githubreleases::is_tag
  )
  $_use_auth = pick(
    $use_auth,
    $githubreleases::use_auth
  )
  $_username = pick_default(
    $username,
    $githubreleases::username
  )
  $_password = pick_default(
    $password,
    $githubreleases::password
  )

  $_target = pick($target, $name)

  # Exit, if target file already exists

  if (file_exists($_target)) {
    debug("Target ${_target} already exists. Skipping")
  } else {

    # Get source URL

    debug("Loading ${_repository}@${_release} by ${_author}")

    if ($_use_zip) {
      debug('Using ZIP')
    }

    if ($_use_auth) {
      debug("Authenticating as ${_username}")
    }

    $source_url = github_release({
      author            => $_author,
      repository        => $_repository,
      release           => $_release,
      asset             => $_asset,
      use_zip           => $_use_zip,
      asset_filepattern => $_asset_filepattern,
      asset_contenttype => $_asset_contenttype,
      asset_fallback    => $_asset_fallback,
      is_tag            => $_is_tag,
      use_auth          => $_use_auth,
      username          => $_username,
      password          => $_password
    })

    remote_file {
      "fetch.${_target}":
        ensure => 'present',
        path   => $_target,
        source => $source_url
    }
  }

}