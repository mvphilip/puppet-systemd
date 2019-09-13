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
