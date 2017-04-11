module Puppet::Parser::Functions
  newfunction(:file_exists, :type => :rvalue, :doc => <<-EOS
Check, if a file exists. Returns true, if it does.

Expects the filepath as its argument.
  EOS
  ) do |args|

    raise(
        Puppet::ParseError,
        'Not enough arguments'
    ) unless args.size == 1

    file = File.expand_path(args[0])

    if File.exists?(file)
      return true
    else
      return false
    end

  end

end