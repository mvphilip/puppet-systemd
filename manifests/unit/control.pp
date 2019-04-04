#
## This function manages a unit's status conditional upon this
## service being present as a systemd service. It can be used in
## situations where puppet has no control the actual service
## installation, but still wants to manage its status.
##
## Parameters:
##
##   unitname       - systemd unit name
##   ensure         - whether the unit should be running or stopped
##   enable         - whether the unit should be enabled, disabled or left alone
##                    This is for units that aren't on some boot target's list
##   reset_on_start - If a unit needs to be started, do a reset of any
##                    failed state as well
##
#
define systemd::unit::control (
  String                               $unitname = $title,
  Optional[Enum['running', 'stopped']] $ensure = undef,
  Optional[Boolean]                    $enable = undef,
  Boolean                              $reset_on_start = false,
) {

  #lint:ignore:selector_inside_resource

  include ::systemd

  ## First, some shorthand to avoid clutter below
  $notpresent   = "${::systemd::sysctl} --no-pager status ${unitname} |& grep -q 'Unit.*could not be found'"
  $isenabled   = "${::systemd::sysctl} is-enabled -q ${unitname}"
  $isactive    = "${::systemd::sysctl} is-active -q ${unitname}"
  $enableunit  = "${::systemd::sysctl} enable ${unitname}"
  $disableunit = "${::systemd::sysctl} disable ${unitname}"
  $startunit   = "${::systemd::sysctl} start ${unitname}"
  $stopunit    = "${::systemd::sysctl} stop ${unitname}"
  $resetunit   = "${::systemd::sysctl} reset-failed ${unitname}"


  ## Reset unit status; called on-demand by 'ensure running' below
  $doreset = exec { "systemd::service::status::reset::${title}":
    command     => $resetunit,
    refreshonly => true,
  }

  #
  ## Set unit activation state, if necessary
  #
  if $ensure != undef {
    exec { "systemd::service::status::ensure::${title}":
      *      => $ensure ? {
        'running' => {
          'command' => $startunit,
          'unless'  => "${notpresent} || ${isactive}",
          'notify'  => $reset_on_start ? { true => $doreset, false => undef },
        },
        'stopped' => {
          'command' => $stopunit,
          'onlyif'  => $isactive,
          'unless'  => $notpresent,
        }
      }
    }
  }

  #
  ## Set unit load status, if necessary
  #
  if $enable != undef {
    exec { "systemd::service::status::enable::${title}":
      * => $enable ? {
        true  => {
          'command' => $enableunit,
          'unless'  => "${notpresent} || ${isenabled}"
        },
        false => {
          'command' => $disableunit,
          'onlyif'  => $isenabled,
          'unless'  => $notpresent
        }
      }
    }
  }

  #lint:endignore:selector_inside_resource
}
