# @summary Downloads release artifacts from Github
# @param release The release or tag to download
# @param asset_filepattern A RegExp filepattern that the requested assed must patch
# @param asset_contenttype A RegExp pattern of the requested content type of the asset
# @param asset Request the download of an asset
# @param asset_fallback If asset can't be found, download a source tar- or zipball instead
# @param use_zip Use a zipball instead of a tarball when requesting non-asset artifacts
# @param is_tag The given release is a tag
# @param use_auth Authenticate with the GitHub API to circumvent rate limiting
# @param author Github author of the requested release
# @param repository Github repository of the requested release
# @param username GitHub username to use
# @param password GitHub password to use
class githubreleases (
  String $release              = 'latest',
  String $asset_filepattern    = '.*',
  String $asset_contenttype    = '.*',
  Boolean $asset               = false,
  Boolean $asset_fallback      = false,
  Boolean $use_zip             = false,
  Boolean $is_tag              = false,
  Boolean $use_auth            = false,
  Optional[String] $author     = undef,
  Optional[String] $repository = undef,
  Optional[String] $username   = '',
  Optional[String] $password   = ''
)
  {

    $githubreleases_download = lookup('githubreleases::download', { merge => hash, default_value => undef })

    if ($githubreleases_download) {
      create_resources('githubreleases::download', $githubreleases_download)
    }

  }
