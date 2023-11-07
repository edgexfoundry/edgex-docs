# Use Case Title
Device Functions

## Submitters
Darryl Mocek (Oracle)

## Changelog

## Market Segments
Any segments using EdgeX with device services with devices that support device functions.

## Motivation
Many devices contain functions that can be called, like the ability to reboot a device.  EdgeX currently does not support the ability to invoke device functions, making parts of devices inaccessible.

## Target Users
Any users using EdgeX with device services with devices that support device functions.

## Description
Some devices support functions, invoking some action on a device, similar to a function in software.  These functions unlock important functionality on the device.

## Existing solutions
EdgeX supports setting attributes on a device.  The workaround for calling device functions currently in EdgeX is to configure a device to call a function when setting at attribute, which isn't always feasible.  For example, to call a 'reboot' device function on a device, a 'reboot' attribute would have to be created and it would have to be set to a value to invoke the reboot function on the device.

## Requirements
Each Device should have a function resource and its parameters defined to support calling the device function with appropriate parameters.

## Related Issues

## References
