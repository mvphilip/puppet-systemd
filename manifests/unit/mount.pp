#
## This function manages a systemd mount unit.
##
## Parameters:
##
##   description    - what this is all about
##   what           - what to mount (e.g. device path or remote path)
##   where          - where to mount (e.g. local mount point)
##   type           - type of mount (e.g. XFS, NFS, BIND, LOOP, ..)
##   *_options      - other systemd directives   (see systemd::unit)
##
#
define systemd::unit::mount (
  String                                    $description,
  String                                    $what,
  String                                    $where,
  String                                    $ensure = 'present',
  Optional[String]                          $type = undef,
  Optional[String]                          $options = undef,
  Optional[Variant[[Array[String],String]]] $wantedby = ['multi-user.target'],

  Hash                                      $unit_options    = {},
  Hash                                      $install_options = {},
  Hash                                      $mount_options   = {},

  Boolean                                   $manage_unitstatus = true,
  Enum['running','stopped']                 $unit_ensure = 'running',
  Boolean                                   $unit_enable = true,
) {

  include ::systemd

  #
  ## mount units place restictions on the unit name: it must
  ## be the mount path with slashes replaced by dashes, except
  ## for the first slash, which must be removed.
  #
  $unit_name = systemd::str2unitname($where)

  systemd::unit { "${title}::mount":
    ensure            => $ensure,
    unit_name         => $unit_name,
    unit_type         => 'mount',

    manage_unitstatus => $manage_unitstatus,
    unit_ensure       => $unit_ensure,
    unit_enable       => $unit_enable,

    unit_options      => $unit_options + { 'Description' => $description, },
    install_options   => $install_options + { 'WantedBy' => $wantedby, },
    type_options      => $mount_options + {
      'What'    => $what,
      'Where'   => $where,
      'Type'    => $type,
      'Options' => $options
    },
  }

}
