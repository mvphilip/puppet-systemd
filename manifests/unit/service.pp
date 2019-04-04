#
## This function manages a simple service file.
##
## Parameters:
##
##   description    - what this is all about
##   servicename    - the systemd service name to configure
##   exec_start     - what to run to start the service
##   exec_stop      - what to run to stop the service
##   user/group     - user/group to impersonate
##   *_options      - other systemd directives   (see systemd::unit)
##
#
define systemd::unit::service (
  String                                    $description,
  Optional[String]                          $service_type = undef,
  Optional[Variant[[Array[String],String]]] $exec_start = undef,
  Optional[Variant[[Array[String],String]]] $exec_stop = undef,
  Optional[Variant[[Array[String],String]]] $exec_reload = undef,
  Optional[String]                          $service_user = undef,
  Optional[String]                          $service_group = undef,
  Optional[String]                          $environment = undef,
  Optional[String]                          $environment_file = undef,
  String                                    $servicename = $title,
  String                                    $ensure = 'present',

  Optional[Hash]                            $unit_options    = {},
  Optional[Hash]                            $install_options = {},
  Optional[Hash]                            $service_options = {},

  Boolean                                   $manage_unitstatus = true,
  Enum['running','stopped']                 $unit_ensure = 'running',
  Boolean                                   $unit_enable = true,
) {

  include ::systemd

  systemd::unit { "${title}::service":
    ensure            => $ensure,
    unit_name         => $servicename,
    unit_type         => 'service',

    manage_unitstatus => $manage_unitstatus,
    unit_ensure       => $unit_ensure,
    unit_enable       => $unit_enable,

    unit_options      => $unit_options + { 'Description' => $description, },
    install_options   => $install_options,
    type_options      => $service_options + {
      'ExecStart'       => $exec_start,
      'ExecStop'        => $exec_stop,
      'ExecReload'      => $exec_reload,
      'Type'            => $service_type,
      'User'            => $service_user,
      'Group'           => $service_group,
      'Environment'     => $environment,
      'EnvironmentFile' => $environment_file,
    }.filter |$k,$v| { !$v.empty },
  }

}
