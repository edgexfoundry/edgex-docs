---
title: Device Service - Device Discovery and Provision Watchers
---

# Device Service - Device Discovery and Provision Watchers

Device Services may contain logic to automatically provision new devices.  This can be done **statically** or **dynamically**.  

### Static Provisioning

In static provisioning, the device service is provided with a Device file which contains the definition(s) of the device(s) to statically provision. The device service connects to and establishes a new device that it manages in EdgeX (specifically metadata) from device definition configuration the device service is provided.  For example, a device service may be provided with the specific IP address and additional device details for a device (or devices) that it is to onboard at startup.  In static provisioning, it is assumed that the device will be there and that it will be available at the address or place specified through the device definition configuration.  The devices and the connection information for those devices is known at the point that the device service starts.

### Dynamic Provisioning

In dynamic provisioning (also known as device discovery), a device service is given some general information about where to look and general parameters for a device (or devices).  For example, the device service may be given a range of network address space and told to look for devices of a certain nature in this range.  However, the device service does not know that the device is physically there – and the device may not be there at start-up.  It must continually scan during its operations (typically on some sort of schedule) for new devices within the guides of the location and device parameters provided by configuration. 

Not all device services support dynamic discovery.  If it does support dynamic discovery, the configuration about what and where to look (in other words, where to scan) for new devices is specified by a provision watcher.  A provision watcher is created via a call to the [core metadata provision watcher API](../../api/core/Ch-APICoreMetadata.md#swagger) (and is stored in the metadata database).

A Provision Watcher is a filter which is applied to any new devices found when a device service scans for devices. It contains a set of ProtocolProperty names and values, these values may be regular expressions. If a new device is to be added, each of these must match the corresponding properties of the new device. Furthermore, a provision watcher may also contain “blocking” identifiers, if any of these match the properties of the new device (note that matching here is *not* regex-based), the device will not be automatically provisioned. This allows the scope of a device scan to be narrowed or allow specific devices to be avoided.  

More than one Provision Watcher may be provided for a device service, and discovered devices are added if they match with any one of them. In addition to the filtering criteria, a Provision Watcher includes specification of various properties to be associated with the new device which matches it: these are the Profile name, the initial AdminState, and optionally any AutoEvents to be applied.

## Admin State

The **adminState** is either `LOCKED` or `UNLOCKED` for each device.  This is an administrative condition applied to the device.  This state is periodically set by an administrator of the system – perhaps for system maintenance or upgrade of the sensor.  When `LOCKED`, requests to the device via the device service are stopped and an indication that the device is locked (HTTP 423 status code) is returned to the caller.

## Sensor Reading Schedule

Data collected from devices by a device service is marshalled into EdgeX event and reading objects which are published to the EdgeX MessageBus.  This is one of the primary responsibilities of a device service.  Typically, a configurable schedule - called an **auto event schedule** - determines when a device service collects the data from the device.
