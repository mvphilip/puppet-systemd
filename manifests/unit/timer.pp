#
## This function manages a systemd timer unit.
##
## Parameters:
##
##   description    - what this is all about
##   on_*           - various flavours of timer periods (see systemd.timer(5))
##   start_unit     - systemd unit to activate when timer goes off
##   *_options      - other systemd directives   (see systemd::unit)
##
#
define systemd::unit::timer (
  String                                    $description,
  Optional[String]                          $on_active = undef,
  Optional[String]                          $on_boot = undef,
  Optional[String]                          $on_startup = undef,
  Optional[String]                          $on_unitactive = undef,
  Optional[String]                          $on_unitinactive = undef,
  Optional[String]                          $start_unit = undef,

  Optional[Variant[[Array[String],String]]] $wantedby = ['timers.target'],
  String                                    $ensure = 'present',
  String                                    $unit_name = $title,

  Hash                                      $unit_options    = {},
  Hash                                      $install_options = {},
  Hash                                      $timer_options   = {},

  Boolean                                   $manage_unitstatus = true,
  Enum['running','stopped']                 $unit_ensure = 'running',
  Boolean                                   $unit_enable = true,
) {

  include ::systemd

  systemd::unit { "${title}::timer":
    ensure            => $ensure,
    unit_name         => $unit_name,
    unit_type         => 'timer',

    manage_unitstatus => $manage_unitstatus,
    unit_ensure       => $unit_ensure,
    unit_enable       => $unit_enable,

    unit_options      => $unit_options + { 'Description' => $description, },
    install_options   => $install_options + { 'WantedBy' => $wantedby, },
    type_options      => $timer_options + {
      'OnActiveSec'       => $on_active,
      'OnBootSec'         => $on_boot,
      'OnStartupSec'      => $on_startup,
      'OnUnitActiveSec'   => $on_unitactive,
      'OnUnitInactiveSec' => $on_unitinactive,
      'Unit'              => $start_unit
    },
  }

}
