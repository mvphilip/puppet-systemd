#
## This function manages a simple service configuration file.
## All parameters correspond to directives in the systemd unit file.
##
#
define systemd::service::simple (
  String $description,
  Variant[[Array[String],String]]           $exec_start,
  Optional[Variant[[Array[String],String]]] $exec_stop = undef,
  Optional[Variant[[Array[String],String]]] $exec_reload = undef,
  Optional[Variant[[Array[String],String]]] $requires = undef,
  Optional[Variant[[Array[String],String]]] $before = undef,
  Optional[Variant[[Array[String],String]]] $after = undef,
  Optional[Variant[[Array[String],String]]] $wantedby = 'multi-user.target',
  Optional[Variant[[Array[String],String]]] $requiredby = undef,
  String                                    $service_type = 'simple',
  Optional[String]                          $service_user = undef,
  Optional[String]                          $service_group = undef,
  Optional[String]                          $working_directory = undef,
  Optional[String]                          $cond_path_is_directory = undef,
  Optional[String]                          $environment = undef,
  Optional[String]                          $environment_file = undef,
  String                                    $restart = 'on-failure',
  String                                    $restart_sec = '5',
  String                                    $start_limit_interval = '120s',
  String                                    $start_limit_burst = '3',
  String                                    $servicename = $title,
  String                                    $ensure = 'present',
  Boolean                                   $manage_unitstatus = true,
  Enum['running','stopped']                 $unit_ensure = 'running',
  Boolean                                   $unit_enable = true,
) {

  include ::systemd

  #
  ## Translate parameters into unit directives and delegate to systemd::unit
  #
  systemd::unit { "${title}::unit::service":
    ensure            => $ensure,
    unit_name         => $servicename,
    unit_type         => 'service',
    manage_unitstatus => $manage_unitstatus,
    unit_ensure       => $unit_ensure,
    unit_enable       => $unit_enable,

    unit_options      => {
      'Description'              => $description,
      'Requires'                 => $requires,
      'Before'                   => $before,
      'After'                    => $after,
      'ConditionPathIsDirectory' => $cond_path_is_directory,
    }.filter |$k,$v| { !$v.empty },

    install_options   => {
      'WantedBy'   => $wantedby,
      'RequiredBy' => $requiredby,
    }.filter |$k,$v| { !$v.empty },

    type_options      => {
      'ExecStart'          => $exec_start,
      'ExecStop'           => $exec_stop,
      'ExecReload'         => $exec_reload,
      'Type'               => $service_type,
      'User'               => $service_user,
      'Group'              => $service_group,
      'Enviroment'         => $environment,
      'EnviromentFile'     => $environment_file,
      'Restart'            => $restart,
      'RestartSec'         => $restart_sec,
      'StartLimitBurst'    => $start_limit_burst,
      'StartLimitInterval' => $start_limit_interval,
      'WorkingDirectory'   => $working_directory,
    }.filter |$k,$v| { !$v.empty }
  }

}
