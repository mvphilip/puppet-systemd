# systemd

## Overview

This module manages systemd configuration files.

## Module Description

Manages systemd unit files in /etc/systemd/system. The base ::systemd class
provides some pertinent system-wide variables. The following defined
types manage systemd unit file instances.


systemd::unit

    manages the content of systemd unit configuration files. Used by
    type specific manifests in the systemd::unit:: namespace.

systemd::unitfrag

    manages the content auxiliary systemd unit configuration files that
    supplements a unit's main configuration. This is useful to manage selected
    unit settings if the main configuration file is maintained by other means,
    e.g. in an application package.

    Example:

      systemd::unitfrag { 'apache:;service::umask':
        ensure       => 'present',
        unit_name    => $::apache::service_name,
        unit_type    => 'service',
        frag_name    => 'umask',
        type_options => { 'UMask' => $service_umask },
        notify       => Service[$::apache::service_name],
      }

     This manages an auxiliary systemd configuration file in '/etc/systemd/system/apache.service.d/'
     that causes the UMask options to merged into the apache service systemd settings.


systemd::service::simple

    manages a simple service unit. Parameters correspond to a subset of
    unit file directives

    Example:

      systemd::service::simple { $service_name:
        description            => 'Tomcat App',
        cond_path_is_directory => $catalina_home,
        service_user           => $user,
        service_group          => $group,
        service_type           => 'forking',
        exec_start             => "${catalina_home}/bin/startup.sh",
        exec_stop              => "${catalina_home}/bin/shutdown.sh",
      }

    Defines a systemd unit that runs a tomcat-based application as a service.



systemd::service::custom

    manages an arbitrary systemd unit file based on a custom configuration
    file source.


The following resources in the systemd::unit namespace have parameters that
represent typical unit-specific configuration options. All of them accept
parameters ('*_options') that allow any systemd options to be configured.
These parameters accept an array of values, which result in systemd directives with values
separated by spaces. The first element in an array of values passed to the pupper resources
is treated specially: if this element is the empty string or the reserved word '__RESET__',
then a systemd configuration line of the form "Directive=" is generated, which effectively
resets this directive in the systemd unit.

Note that in all system::unit resources, the 'description' parameter is mandatory.


systemd::unit::mount

    manages a systemd mount unit.

systemd::unit::automount

    manages a systemd automount unit and also the accompanying mandatory
    mount unit.

    Example:

      systemd::unit::automount { 'rhome':
        ensure       => present,
        description  => 'Remote home directories volumes',
        where        => '/home',
        what         => 'stores.example.org:/home',
        type         => 'nfs',
        options      => 'nolock,noatime,bg',
        idle_timeout => 900
      }

    Defines both a systemd automount and its associated mount unit to manage a
    NFS-based remote volume with automatic unmount after 15 minutes of inactivity.


systemd::unit::service

    manages a systemd service unit.


systemd::unit::socket

    manages a systemd socket unit.


systemd::unit::timer

    manages a systemd timer unit.


systemd::unit::path

    manages a systemd path unit.

