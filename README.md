# dodevops/githubreleases

[![Build status](https://img.shields.io/travis/dodevops/puppet-githubreleases.svg)](https://travis-ci.org/dodevops/puppet-githubreleases)

#### Table of Contents

1. [Description](#description)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    1. [Class githubreleases](#class-githubreleases)
    1. [Type githubreleases::download](#type-githubreleasesdownload)

## Description

This puppet module downloads tar-, zipballs or assets from Github releases.

Assets can be filtered by Content type and/or file name.

## Usage

To download a release from Github, use the defined type githubreleases_download like this:

```puppet
githubreleases_download {
  '/tmp/release.latest.head.tar.gz':
    author     => 'company',
    repository => 'example'
}
```

This will download the latest (HEAD) version of the project "company/example" as a tarball
 an place it in /tmp/release.latest.head.tar.gz.

If the repository uses the Github release feature, the tarball of the
latest (non-pre-release) release will be downloaded.

If the repository uses assets to offer binary files with each release,
these can also be downloaded:

```puppet
githubreleases_download {
  '/tmp/release.0.0.2.asset.debian':
    author            => 'company',
    repository        => 'example',
    release           => '0.0.2',
    asset             => true,
    asset_contenttype => 'application\/x-deb'
}
```

This will download a debian package of release 0.0.2 of the repository.

File names can be filtered as well:

```puppet
githubreleases_download {
  '/tmp/release.0.0.2.asset.exe':
    author            => 'company',
    repository        => 'example',
    release           => '0.0.2',
    asset             => true,
    asset_filepattern => 'example.*\.exe'
}
```

This will download the first file matching the given filepattern.

All patterns are Regular Expressions.

This module also supports hiera. Just include the githubreleases-class and
use the type like this:

```yaml
githubreleases_download:
  '/tmp/release.latest.head.fromhiera.tar.gz':
    author: 'company'
    repository: 'example'
```

Defaults for multiple resources can be set by configuring the githubreleases-class.

## Using authentication

Github [rate-limits](https://developer.github.com/v3/#rate-limiting) access
to its API. If you use this module in a test and massively download files
using it, you better create a Github user and set the authentication parameters
so that you will get a better rate.
