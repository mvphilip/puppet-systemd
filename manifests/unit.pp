#
## This function manages the content and installation of a systemd
## unit configuration file. Information is provided through service-specific
## front-ends in the systemd::unit:: namespace and passed in the
## '*_options' parameters as explanined below. Note that the content of
## these parameters is converted to systemd configuration format, but
## is not otherwise validated. Remember that section and directove names
## are case-sensitive; some support for section name spelling is present
## in this module, but directives are left alone.
##
## Parameters:
##
##  ensure             - presence or absence of systemd unit file
##  servicetype        - one of the systemd unit types (e.g. service, mount)
##  servicename        - name of systemd service (encoded in unit file)
##  manage_unitstatus  - if true, also manage the unit's load and activation
##                       status, controlled by 'unit_ensure' and 'unit_enable'
##  unit_status        - if manage_unitstatus, set the unit's activation status 
##  unit_enable        - if true and manage_unitstatus is true, enable the unit
##  unit_options       - directives for the [Unit] section
##  install_options    - directives for the [Install] section
##  type_options       - directives for the service-specific section
##                       (e.g. [Service], [Mount], etc..)
#
define systemd::unit (
  Enum['present','absent']            $ensure,
  String                              $unit_type,
  String                              $unit_name = $title,
  Hash                                $unit_options = {},
  Hash                                $install_options = {},
  Hash                                $type_options = {},
  Boolean                             $manage_unitstatus = false,
  Optional[Enum['stopped','running']] $unit_ensure = undef,
  Optional[Boolean]                   $unit_enable = undef,
) {

  include ::systemd

  ## Construct the unit file name
  $filename = "${::systemd::system_basedir}/${unit_name}.${unit_type}"

  #
  ## Construct the unit file content.
  ## This is an EPP template and uses puppet helper function 'formatkv()'
  ## which is defined elsewhere in this module.
  #
  $unitcontent = @(UNITCONTENT)
    ## THIS UNIT CONFIGURATION FILE IS MANAGED BY PUPPET; cf. systemd::unit
    <%= systemd::formatkv('Unit',$unit_options) %>

    <%= systemd::formatkv($unit_type.capitalize, $type_options) %>

    <%= systemd::formatkv('Install', $install_options) %>
    | UNITCONTENT

  #
  ## Manage the systemd unit file from the specified content and notify
  ## the system loader, if necessary
  #
  file { $filename :
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => inline_epp($unitcontent),
    before  => $::systemd::daemon_reload,
    notify  => $::systemd::daemon_reload
  }

  #
  ## Manage the unit's status, if requested.
  ## If the unit is of type 'service', then use the standard puppet
  ## service resource, so our clients can use it as a target for
  ## notifications.
  #
  if $manage_unitstatus and $ensure == 'present' {
    ensure_resource('service', "${unit_name}.${unit_type}", {
      ensure   => $unit_ensure,
      enable   => $unit_enable,
      provider => 'systemd',
      require  => $::systemd::daemon_reload
    })
  }

}
