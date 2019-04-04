#
## This function manages a systemd socket unit.
##
## Parameters:
##
##   description  - what this is all about
##   listen_*     - various flavours of socket addresses (see systemd.socket(5))
##   start_unit   - systemd unit to activate on socket activity
##   *_options    - other systemd directives   (see systemd::unit)
##
#
define systemd::unit::socket (
  String                                    $description,
  Optional[String]                          $listen_stream = undef,
  Optional[String]                          $listen_datagram = undef,
  Optional[String]                          $listen_sequential = undef,
  Optional[String]                          $listen_mqueue = undef,
  Optional[String]                          $start_unit = undef,

  Optional[Variant[[Array[String],String]]] $wantedby = ['sockets.target'],
  String                                    $ensure = 'present',
  String                                    $unit_name = $title,

  Hash                                      $unit_options    = {},
  Hash                                      $install_options = {},
  Hash                                      $socket_options   = {},

  Boolean                                   $manage_unitstatus = true,
  Enum['running','stopped']                 $unit_ensure = 'running',
  Boolean                                   $unit_enable = true,
) {

  include ::systemd

  systemd::unit { "${title}::socket":
    ensure            => $ensure,
    unit_name         => $unit_name,
    unit_type         => 'socket',

    manage_unitstatus => $manage_unitstatus,
    unit_ensure       => $unit_ensure,
    unit_enable       => $unit_enable,

    unit_options      => $unit_options + { 'Description' => $description, },
    install_options   => $install_options + { 'WantedBy' => $wantedby, },
    type_options      => $socket_options + {
      'ListenStream'       => $listen_stream,
      'ListenDatagram'     => $listen_datagram,
      'ListenSequential'   => $listen_sequential,
      'ListenMessageQueue' => $listen_mqueue,
      'Service'            => $start_unit
    },
  }

}
