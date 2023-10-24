---
title:  Device Service - Getting Started
---

# Device Service - Getting Started

## Device Service - Functionality

All device services must perform the following tasks:

- Register with core metadata – thereby letting all of EdgeX know that it is running and stands ready to manage devices.  In the case of an existing device service, the device service will update its metadata registration and get any new information.
- Get its configuration settings from the EdgeX’s configuration service (or local configuration file if the configuration service is not being used).
- Register itself an EdgeX running micro service with the EdgeX registry service (when running) – thereby allowing other EdgeX services to communicate with it.
- On-board and manage physical devices it knows how to communicate with.  This process is called provisioning of the device(s).  In some cases, the device service may have the means to automatically detect and provision the devices.  For example, a BLE device service may automatically scan a BLE address space, detect a new BLE device in its range, and then provision that device to EdgeX and the associated BLE device service.
- Update and inform EdgeX on the operating state of the device (does it appear the device is still running and able to communicate).
- Monitor for configuration changes and apply new configuration where applicable.  Note, in some cases configuration changes cannot be dynamically applied (example: change the operating port of the device service).
- Get sensor data (i.e. ingest sensor data) and pass that data to the core data micro service via REST.
- Receive and react to REST based actuation commands.

As you can imagine, many of these tasks (like registering with core metadata) are generic and the same for all device services and thereby provided by the SDK.  Other tasks (like getting sensor data from the underlying device) are quite specific to the underlying device.  In these cases, the device service SDK provides empty functions for performing the work, but the developer would need to fill in the function code as it relates to the specific device, the communication protocol, device driver, etc.

### Device Service Functional Requirements

[Requirements for the device service](../../design/legacy-requirements/device-service.md) are provided in this documentation. These
requirements are being used to define what functionality needs to be
offered via any Device Service SDK to produce the device service
scaffolding code. They may also help the reader further understand the duties
and role of a device service.