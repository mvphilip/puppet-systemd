#
## This function manages a systemd path unit.
##
## A path unit watches for file or directory activity on a given path
## whereupon it starts another systemd unit (such as a 'oneshot' service)
## to deal with it.
##
## Parameters:
##
##   description    - what this is all about
##   path_*         - various flavours of path watching (see systemd.path(5))
##   start_unit     - systemd unit to activate when path monitor triggers
##   *_options      - other systemd directives   (see systemd::unit)
##
#
define systemd::unit::path (
  String                                    $description,
  Optional[String]                          $path_exists = undef,
  Optional[String]                          $path_exists_glob = undef,
  Optional[String]                          $path_changed = undef,
  Optional[String]                          $path_modified = undef,
  Optional[String]                          $dir_notempty = undef,
  Optional[String]                          $start_unit = undef,

  Boolean                                   $make_directory = true,
  Optional[String]                          $directory_mode = '0755',

  Optional[Variant[[Array[String],String]]] $wantedby = ['paths.target'],
  String                                    $ensure = 'present',
  String                                    $unit_name = $title,

  Hash                                      $unit_options    = {},
  Hash                                      $install_options = {},
  Hash                                      $path_options   = {},

  Boolean                                   $manage_unitstatus = true,
  Enum['running','stopped']                 $unit_ensure = 'running',
  Boolean                                   $unit_enable = true,
) {

  include ::systemd

  systemd::unit { "${title}::path":
    ensure            => $ensure,
    unit_name         => $unit_name,
    unit_type         => 'path',

    manage_unitstatus => $manage_unitstatus,
    unit_ensure       => $unit_ensure,
    unit_enable       => $unit_enable,

    unit_options      => $unit_options + { 'Description' => $description, },
    install_options   => $install_options + { 'WantedBy' => $wantedby, },
    type_options      => $path_options + {
      'PathExists'        => $path_exists,
      'PathExistsGlob'    => $path_exists_glob,
      'PathChanged'       => $path_changed,
      'PathModified'      => $path_modified,
      'DirectoryNotEmpty' => $dir_notempty,
      'MakeDirectory'     => String($make_directory),
      'DirectoryMode'     => $directory_mode,
      'Unit'              => $start_unit
    },
  }

}
