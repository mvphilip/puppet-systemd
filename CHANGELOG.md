# Change log

## Release [1.2.0]
### Summary
Feature: systemd::service::simple: make all systemd settings available through parameters
systemd::unit::timer bug fix

#### Added
- systemd::dropin_file: this defined resource for compatibility with the voxpopuli module which also occupies the '::systemd' namespace.

#### Fixed
- systemd::unit::timer: fix errors in type_option values


## Release [1.1.0]
### Summary
Feature: systemd directive reset option

#### Added
- systemd::functions::formatkv: support for resetting multi-valued systemd unit directives


## Release [1.0.1]
### Summary
Bugfix release

#### Fixed
- systemd::service::simple_service: fix spelling of 'Environment' parameters
- systemd::functions::formatkv: remove space form key/value declaration (from runejuhl)

