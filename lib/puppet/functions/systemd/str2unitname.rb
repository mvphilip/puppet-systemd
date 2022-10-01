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

    #input = s[/.(.*)/m,1]
    input = s
    if system('which systemd-escape') == true
      output = `systemd-escape -p --suffix=mount #{input}`
    else
      input = input.gsub(/-/,'\\x2d')
      input = input.gsub(/\//,'-')
      output = input
    end
    notify {"SYSTEMD-OUT : ${output}" }
    return output.chomp
  end

end
