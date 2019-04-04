#
## This function manages the content and installation of an auxiliary systemd
## unit configuration file that supplements a unit's main configuration.
##
## This is useful to manage unit settings if the main configuration file
## is maintained by other means, e.g. from an application package.
##
## Information is provided through '*_options' parameters in the same
## Note that the 'Install' section is absent, because it won't have
## any effect in an auxiliary unit configuration file.
##
## Parameters:
##
##  ensure             - presence or absence of systemd unit file
##  frag_name          - name of this configuration fragment
##  unit_type          - type of systemd unit being augmented
##  unit_name          - the systemd unit being augmented
##  unit_options       - directives for the [Unit] section
##  type_options       - directives for the service specific section
##                       (e.g. [Service], [Mount], etc..)
#
define systemd::unitfrag (
  Enum['present','absent']            $ensure,
  String                              $unit_type,
  String                              $unit_name,
  String                              $frag_name = $title,
  Hash                                $unit_options = {},
  Hash                                $type_options = {},
) {

  include ::systemd

  ## Construct the unit file name
  $dirname = "${::systemd::system_basedir}/${unit_name}.${unit_type}.d"
  $filename = "${dirname}/${frag_name}.conf"

  #
  ## Construct the unit file content.
  ## This is an EPP template and uses puppet helper function 'formatkv()'
  ## which is defined elsewhere in this module.
  #
  $unitcontent = @(UNITCONTENT)
    ## THIS UNIT CONFIGURATION FILE IS MANAGED BY PUPPET; cf. systemd::unit
    <%= systemd::formatkv('Unit',$unit_options) %>

    <%= systemd::formatkv($unit_type.capitalize, $type_options) %>
    | UNITCONTENT

  #
  ## Manage the systemd unit file from the specified content and notify
  ## the system loader, if necessary
  #
  file { $dirname :
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  -> file { $filename :
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => inline_epp($unitcontent),
    before  => $::systemd::daemon_reload,
    notify  => $::systemd::daemon_reload
  }

}
