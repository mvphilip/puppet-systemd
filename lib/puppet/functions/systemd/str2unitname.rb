#
## Convert a string for use as a systemd unit name
## See systemd.unit(5) for the escaping algorithm
#
Puppet::Functions.create_function(:'systemd::str2unitname') do

  dispatch :unitname do
    required_param 'String', :s
    optional_param 'Boolean', :pathmode
  end

  def unitname(s, pathmode=true)
    t = s

    # In path mode, drop leading and trailing slashes, then collapse duplicates
    t = t.gsub(/\/\/+/,'/').gsub(/\/$/,'').gsub(/^\//,'') if (pathmode)

    # In path mode, if the result is now empty, we'll make
    # it represent the root directory
    return '-' if t.empty?

    # \x<nn> escape all chars except alpha-numerics, underbars, slashes and dots
    t = t.gsub(/([^A-Za-z0-9_\/.])/) { |c| "\\x#{c.ord.to_s(16)}" }

    # Replace all remaining slashes with hyphens
    # and escape any remaining leading dot
    return t.gsub(/\//,'-').gsub(/^\./, '\\x2e')
  end

end
