#
## This function manages a service's status conditional upon this
## service being present as a systemd service. It can be used in
## situations where puppet has no control the actual service
## installation, but still wants to manage its status.
##
## Parameters:
##
##   servicename    - systemd service name
##   ensure         - whether the service should be running or stopped
##   enable         - whether the service should be enabled or not
##
#
define systemd::service::control (
  String                     $servicename = $title,
  Enum['running', 'stopped'] $ensure = 'running',
  Boolean                    $enable = false,
) {

  systemd::unit::control { $title:
    ensure   => $ensure,
    enable   => $enable,
    unitname => $servicename,
  }

}
