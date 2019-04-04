#
## systemd configuration file management
##
## Note: the main ::systemd module only manages some global helper resources.
## Actual systemd configuration is managed by manifests in the systemd::unit
## and systemd::service namespaces.
#
class systemd {

  ## global configuration
  $system_basedir = '/etc/systemd/system'
  $sysctl = '/usr/bin/systemctl'

  ## utility: reload configuration after changes
  $daemon_reload = exec { "${title}::daemon::reload":
    command     => "${sysctl} daemon-reload",
    refreshonly => true,
  }

  ## utility: reset failed status after corrective changes
  $reset_failed = exec { "${title}::daemon::reset_failed":
    command     => "${sysctl} reset-failed",
    refreshonly => true,
  }

}

#
## Helper function that turns a section + key-value hash into
## systemd.unit section directives.
##
## Notes:
##   The section header is included in the output
##   Empty values are filtered out
##   Values of type ARRAY are converted to a space-separated string
#
function systemd::formatkv($section,$h) {

  #
  ## Output section header and append one directive for each KV pair in
  ## the hash. Note: if hash is empty, no output is produced
  #
  $directives = $h.reduce('') |$memo,$v| {
    $s = [$v[1]].flatten.filter |$a| { !empty($a) }.join(' ')
    empty($s) ? { false => "${memo}\n${v[0]} = ${s}", true => $memo }
  }

  if empty($directives) { return('') }

  "[${section}]${directives}"

}
