---
title: Device Service - Device Discovery and Provision Watchers
---

# Device Service - Test and Demonstration Device Services

Among the many available device services provided by EdgeX, there are two device services that are typically used for demonstration, education and testing purposes only.  The random device service ([device-random-go](https://github.com/edgexfoundry/device-random)) is a very simple device service used to provide device service authors a bare bones example inclusive of a device profile.  It can also be used to create random integer data (either 8, 16, or 32 bit signed or unsigned) to simulate integer readings when developing or testing other EdgeX micro services. It was created from the Go-based device service SDK.

The virtual device service ([device-virtual-go](https://github.com/edgexfoundry/device-virtual-go)) is also used for demonstration, education and testing.  It is a more complex simulator in that it allows any type of data to be generated on a scheduled basis and used an embedded SQL database (ql) to provide simulated data.  Manipulating the data in the embedded database allows the service to mimic almost any type of sensing device.   More information on the [virtual device service](services/device-virtual/Ch-VirtualDevice.md) is available in this documentation.

## Running multiple instances

Device services support one additional command-line argument, `--instance` or `-i`. This allows for running multiple instances of a device service in an EdgeX deployment, by giving them different names.

For example, running `device-modbus -i 1` results in a service named `device-modbus_1`, ie the parameter given to the `instance` argument is added as a suffix to the device service name. The same effect may be obtained by setting the `EDGEX_INSTANCE_NAME` environment variable.

## Publish to MessageBus

Device services now have the capability to publish Events directly to the EdgeX MessageBus, rather than POST the Events to Core Data via REST. This capability is controlled by the `Device.UseMessageBus` configuration property (see below), which is set to `true` by default. Core Data is configured by default to subscribe to the EdgeX MessageBus to receive and persist the Events. Application services, as in EdgeX 1.x, subscribe to the EdgeX MessageBus to receive and process the Events.

!!! edgey "Edgex 3.0"
    Upon successful PUT command, Device services will also publish an Event with the updated Resource value(s) to the EdgeX MessageBus as long as the Resource(s) are not write-only.