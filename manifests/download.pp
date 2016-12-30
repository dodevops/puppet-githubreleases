define githubreleases::download (
  $author            = undef,
  $repository        = undef,
  $release           = undef,
  $asset             = undef,
  $use_zip           = undef,
  $asset_filepattern = undef,
  $asset_contenttype = undef,
  $asset_fallback    = undef,
  $target            = undef
) {

  include githubreleases

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

  $_target = pick($target, $name)

  $_url_prefix = 'https://api.github.com/repos'

  $release_info = loadjson(
    "${_url_prefix}/${_author}/${_repository}/releases/${_release}",
    { }
  )

  if ($_asset) {
    if (size($release_info['assets']) == 0) {
      fail('Asset not found')
    } else {
      githubreleases::scan {
        $release_info['assets']:
          filepattern => $_asset_filepattern,
          contenttype => $_asset_contenttype,
          target      => $_target
      }
    }
  }

  if (!$_asset) or ($_asset_fallback) {
    if ($_use_zip) {
      remote_file {
        "fetch.${_target}":
          ensure => 'present',
          path   => $_target,
          source => $release_info['zipball_url']
      }
    } else {
      remote_file {
        "fetch.${_target}":
          ensure => 'present',
          path   => $_target,
          source => $release_info['tarball_url']
      }
    }
  }

}