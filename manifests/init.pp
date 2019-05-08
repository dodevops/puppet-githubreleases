class githubreleases (
  $author            = undef,
  $repository        = undef,
  $release           = 'latest',
  $asset             = false,
  $use_zip           = false,
  $asset_filepattern = '.*',
  $asset_contenttype = '.*',
  $asset_fallback    = false,
  $is_tag            = false,
  $use_auth          = false,
  $username          = '',
  $password          = ''
)
  {

    $githubreleases_download = hiera_hash('githubreleases::download', undef)

    if ($githubreleases_download) {
      create_resources('githubreleases::download', $githubreleases_download)
    }

  }
