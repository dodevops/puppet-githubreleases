lookup('classes', { merge => unique, default_value => undef }).include

$_use_auth = $facts['github_use_auth'] ? {
  # lint:ignore:quoted_booleans
  'true'  => true,
  # lint:endignore
  default => false,
}

$_use_oauth = $facts['github_use_oauth'] ? {
  # lint:ignore:quoted_booleans
  'true'  => true,
  # lint:endignore
  default => false,
}

::githubreleases::download {
  '/tmp/release.latest.head.tar.gz':
    author     => 'Graylog2',
    repository => 'collector-sidecar',
    use_auth   => $_use_auth,
    use_oauth  => $_use_oauth,
    username   => $facts['github_username'],
    password   => $facts['github_password'],
}

::githubreleases::download {
  '/tmp/release.0.0.2.head.tar.gz':
    author     => 'Graylog2',
    repository => 'collector-sidecar',
    release    => '0.0.2',
    is_tag     => true,
    use_auth   => $_use_auth,
    use_oauth  => $_use_oauth,
    username   => $facts['github_username'],
    password   => $facts['github_password'],
}

::githubreleases::download {
  '/tmp/release.0.0.2.head.zip':
    author     => 'Graylog2',
    repository => 'collector-sidecar',
    release    => '0.0.2',
    use_zip    => true,
    is_tag     => true,
    use_auth   => $_use_auth,
    use_oauth  => $_use_oauth,
    username   => $facts['github_username'],
    password   => $facts['github_password'],
}

::githubreleases::download {
  '/tmp/release.0.0.2.asset.debian':
    author            => 'Graylog2',
    repository        => 'collector-sidecar',
    release           => '0.0.2',
    asset             => true,
    asset_contenttype => 'application\/x-deb',
    is_tag            => true,
    use_auth          => $_use_auth,
    use_oauth         => $_use_oauth,
    username          => $facts['github_username'],
    password          => $facts['github_password'],
}

::githubreleases::download {
  '/tmp/release.0.0.2.asset.exe':
    author            => 'Graylog2',
    repository        => 'collector-sidecar',
    release           => '0.0.2',
    asset             => true,
    asset_filepattern => 'graylog_collector_sidecar_installer.*\.exe',
    is_tag            => true,
    use_auth          => $_use_auth,
    use_oauth         => $_use_oauth,
    username          => $facts['github_username'],
    password          => $facts['github_password'],
}
