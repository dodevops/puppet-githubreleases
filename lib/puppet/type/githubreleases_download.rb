Puppet::Type.newtype('githubreleases_download') do
  @doc = 'downloads release artifacts from Github'

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:target, namevar: true) do
    desc 'Target path to use (defaults to name of the ressource)'
  end
  newparam(:release) do
    desc 'The release or tag to download'
    defaultto 'latest'
  end
  newparam(:asset_filepattern) do
    desc 'A RegExp filepattern that the requested assed must patch'
    defaultto '.*'
  end
  newparam(:asset_contenttype) do
    desc 'A RegExp pattern of the requested content type of the asset'
    defaultto '.*'
  end
  newparam(:asset, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'Request the download of an asset'
    defaultto false
  end
  newparam(:asset_fallback, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'If asset can\'t be found, download a source tar- or zipball instead'
    defaultto false
  end
  newparam(:use_zip, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'Use a zipball instead of a tarball when requesting non-asset artifacts'
    defaultto false
  end
  newparam(:is_tag, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'The given release is a tag'
    defaultto false
  end
  newparam(:use_auth, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'Authenticate with the GitHub API to circumvent rate limiting'
    defaultto false
  end
  newparam(:use_oauth, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'Use OAuth authentication instead of basic authentication.'
    defaultto false
  end
  newparam(:author) do
    desc 'Github author of the requested release'
  end
  newparam(:repository) do
    desc 'Github repository of the requested release'
  end
  newparam(:username) do
    desc 'GitHub username to use'
    defaultto ''
  end
  newparam(:password) do
    desc 'GitHub password to use'
    defaultto ''
  end
end
