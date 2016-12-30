define githubreleases::scan (
  $filepattern,
  $contenttype,
  $target
) {

  $_content_type = $name['content_type']

  if
  ($contenttype in $name['content_type']) and
    ($filepattern in $name['name'])
  {
    remote_file {
      "fetch.${target}":
        ensure => 'present',
        path   => $target,
        source => $name['browser_download_url']
    }
  }
}