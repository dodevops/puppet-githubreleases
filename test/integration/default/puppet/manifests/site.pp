hiera_include('classes', undef)

githubreleases::download {
  '/tmp/release.latest.head.tar.gz':
    author     => 'Graylog2',
    repository => 'collector-sidecar'
}

githubreleases::download {
  '/tmp/release.0.0.2.head.tar.gz':
    author     => 'Graylog2',
    repository => 'collector-sidecar',
    release    => '0.0.2',
    is_tag     => true
}

githubreleases::download {
  '/tmp/release.0.0.2.head.zip':
    author     => 'Graylog2',
    repository => 'collector-sidecar',
    release    => '0.0.2',
    use_zip    => true,
    is_tag     => true
}

githubreleases::download {
  '/tmp/release.0.0.2.asset.debian':
    author            => 'Graylog2',
    repository        => 'collector-sidecar',
    release           => '0.0.2',
    asset             => true,
    asset_contenttype => 'application\/x-deb',
    is_tag            => true
}

githubreleases::download {
  '/tmp/release.0.0.2.asset.exe':
    author            => 'Graylog2',
    repository        => 'collector-sidecar',
    release           => '0.0.2',
    asset             => true,
    asset_filepattern => 'graylog_collector_sidecar_installer.*\.exe',
    is_tag            => true
}