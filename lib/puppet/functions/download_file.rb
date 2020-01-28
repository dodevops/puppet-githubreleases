require 'open-uri'

Puppet::Functions.create_function(:download_file) do
  dispatch :default do
    param 'String', :source
    param 'String', :target
  end

  def default(
    source,
    target
  )
    download = open(source)
    IO.copy_stream(download, target)
  end
end
