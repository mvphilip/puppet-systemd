#
## This function manages an automount systemd unit.
## An automount unit must always be accompanyied by a mount unit
## that will be automatically activated when the automount path
## is accessed. See systemd.automount(5) for details.
##
## By default, both the mount and automount systemd unit are configured here.
##
## Parameters:
##
##   description    - what this is all about
##   what           - what to mount (e.g. device path or remote path)
##   where          - where to mount (e.g. local mount point)
##   type           - type of mount (e.g. XFS, NFS, BIND, LOOP, ..)
##   options        - mount options (e.g. async, ro, nodev, ..)
##   idle_timout    - timespan until automatic unmount when idle
##   directory_mode - access mode for auto-created mountpoint path components
##   manage_mount   - whether to manage the accompanying mount unit
##
##   *_options      - other systemd directives   (see systemd::unit)
##
#
define systemd::unit::automount (
  String                                    $description,
  String                                    $what,
  String                                    $where,
  String                                    $ensure = 'present',
  Optional[String]                          $type = undef,
  Optional[String]                          $custom_name = undef,
  Optional[String]                          $options = undef,
  Optional[String]                          $idle_timeout = undef,
  Optional[String]                          $directory_mode = '0755',
  Boolean                                   $manage_mount_unit = true,
  Optional[Variant[[Array[String],String]]] $wantedby = ['multi-user.target'],

  Hash                                      $unit_options      = {},
  Hash                                      $install_options   = {},
  Hash                                      $mount_options     = {},
  Hash                                      $automount_options = {},

  Boolean                                   $manage_unitstatus = true,
  Enum['running','stopped']                 $unit_ensure = 'running',
  Boolean                                   $unit_enable = true,
) {

  include ::systemd

  #
  ## mount and automount units place restictions on the unit name:
  ## it must be the mount path with slashes replaced by dashes, except
  ## for the first slash, which must be removed.
  #
  
  # $unit_name = systemd::str2unitname($where)
  $unit_name = $custom_name ? {
       "" => systemd::str2unitname($where),
       default => $custom_name
  }
  
  ## Configure the automount unit
  systemd::unit { "${title}::automount":
    ensure            => $ensure,
    unit_name         => $unit_name,
    unit_type         => 'automount',

    manage_unitstatus => $manage_unitstatus,
    unit_ensure       => $unit_ensure,
    unit_enable       => $unit_enable,

    unit_options      => $unit_options + { 'Description' => $description, },
    install_options   => $install_options + { 'WantedBy' => $wantedby, },
    type_options      => $automount_options + {
      'Where'          => $where,
      'DirectoryMode'  => $directory_mode,
      'TimeoutIdleSec' => $idle_timeout
    },
  }

  ## XXX - automount units should auto-create mountpoints
  ##       but see radhat bug 1585411 for why we must do it ourselves for now..
  if $ensure == 'present' {
    exec { "${title}::mkwhere" :
      command => "/bin/mkdir -p '${where}'",
      umask   => String(0777 - Integer($directory_mode), '%#o'),
      creates => $where,
      before  => Systemd::Unit["${title}::automount"]
    }
  }


  unless $manage_mount_unit { return() }

  #
  ## Configure the accompanying mount unit
  ##
  ## For the automount/mount combo to work as expected, the mount
  ## unit should remain disabled and stopped. It will be started and
  ## stopped only on demand by events on the automount unit.
  #
  systemd::unit { "${title}::mount":
    ensure            => $ensure,
    unit_name         => $unit_name,
    unit_type         => 'mount',
    manage_unitstatus => false,
    unit_options      => { 'Description' => $description, },
    install_options   => {},
    type_options      => {
      'What'    => $what,
      'Where'   => $where,
      'Type'    => $type,
      'Options' => $options
    },
  }

}
