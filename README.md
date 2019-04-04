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

systemd::service::simple

    manages a simple service unit. Parameters correspond to a subset of
    unit file directives

systemd::service::custom

    manages an arbitrary systemd unit file based on a custom configuration
    file source.

The following resources in the systemd::unit namespace have parameters that
represent typical unit-specific configuration options. All of them accept
parameters ('*_options') that allow any systemd options to be configured.

systemd::unit::mount

    manages a systemd mount unit.

systemd::unit::automount

    manages a systemd automount unit and also the accompanying mandatory
    mount unit.

systemd::unit::service

    manages a systemd service unit.

systemd::unit::socket

    manages a systemd socket unit.

systemd::unit::timer

    manages a systemd timer unit.

systemd::unit::path

    manages a systemd path unit.

