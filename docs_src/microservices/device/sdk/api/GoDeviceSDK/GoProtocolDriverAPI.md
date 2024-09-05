---
title: Device Service SDK - Protocol Driver API
---

# Device Service SDK - Protocol Driver API

The **Protocol Driver API** is an `interface` that must be implemented by all device services. 
This interface provides entry points for the Device SDK to call into the custom device service driver code.
Implementation of this interface is the heart of all devices services as the Device SDK takes care of the rest of what it means to be a Device Service.

## ProtocolDriver Interface

```go
type ProtocolDriver interface {
	Initialize(sdk DeviceServiceSDK) error
	Start() error
	Stop(force bool) error
    Discover() error
    AddDevice(deviceName string, protocols map[string]models.ProtocolProperties, adminState models.AdminState) error
    UpdateDevice(deviceName string, protocols map[string]models.ProtocolProperties, adminState models.AdminState) error
	RemoveDevice(deviceName string, protocols map[string]models.ProtocolProperties) error
	ValidateDevice(device models.Device) error
    HandleReadCommands(deviceName string, protocols map[string]models.ProtocolProperties, reqs []sdkModels.CommandRequest) ([]*sdkModels.CommandValue, error)
    HandleWriteCommands(deviceName string, protocols map[string]models.ProtocolProperties, reqs []sdkModels.CommandRequest, params []*sdkModels.CommandValue) error
}
```
### Driver

The interfaces in this section deal with the driver implemented by the device service

#### Initialize

`Initialize(sdk DeviceServiceSDK) error`

This interface performs protocol-specific initialization for the device service. 
The `sdk` parameter gives access to [Device Service SDK API](GoDeviceSDKAPI.md) for performing initialization tasks. 
This is where custom configuration can be loaded and watcher setup. See [Custom Configuration](../../details/CustomConfiguration.md) section for more details.

An example implementation can be found in the Device SDK's example [Simple Driver](https://github.com/edgexfoundry/device-sdk-go/blob/{{edgexversion}}/example/driver/simpledriver.go)

#### Start

`Start() error`

This interface runs Device Service startup tasks after the SDK and driver have been completely initialized.
This allows Device Service to safely use all DeviceServiceSDK interface features in this function call.

#### Stop

`Stop(force bool) error`

This interface instructs the protocol-specific code to shut down gracefully, or if the force parameter is 'true', immediately.
The driver is responsible for closing any in-use channels, including the channel used to send async readings (if supported).

### Device

The interfaces in this section deal with devices that the devices service manages

#### Discover

`Discover() error`

This interface triggers protocol specific device discovery, asynchronously writes the results to the channel which is return 
by the `DeviceServiceSDK.DiscoveredDeviceChannel()` API. The resulting devices may be added to the device service based
on a set of acceptance criteria (i.e. Provision Watchers). See `Device Discovery` section for more details.

If the device service does not implement protocol specific device discovery, it should return an error since Device Discovery 
should not be enabled in the service's configuration. See **Device** tab in [Configuration](../../../Configuration.md) section for more details.

An example implementation can be found in the Device SDK's example [Simple Driver](https://github.com/edgexfoundry/device-sdk-go/blob/{{edgexversion}}/example/driver/simpledriver.go)

#### ValidateDevice

`ValidateDevice(device models.Device) error`

This interface triggers device's protocol properties validation. An error is returned if validation failed which blocks
the incoming device from being added into EdgeX.

An example implementation can be found in the Device SDK's example [Simple Driver](https://github.com/edgexfoundry/device-sdk-go/blob/{{edgexversion}}/example/driver/simpledriver.go)

#### AddDevice

`AddDevice(deviceName string, protocols map[string]models.ProtocolProperties, adminState models.AdminState) error`

This interface is a called when a new device had been added for the device service to manage. This is where the device service 
may perform protocol specific actions to initialize communication with the device instance.

#### UpdateDevice

`UpdateDevice(deviceName string, protocols map[string]models.ProtocolProperties, adminState models.AdminState) error`

This interface is called when a device already managed by the device service has been updates. This may require reestablishing 
communication with the device instance due to the changes. 

#### RemoveDevice

`RemoveDevice(deviceName string, protocols map[string]models.ProtocolProperties) error`

This interface is called when a device managed by the device service has been removed from EdgeX. This may require the 
device service to take action to shut down communication with the device instance.

### Commands

The interfaces in this section deal with commands received by the device service.
See [Device Commands](../../../details/DeviceCommands.md) for more details about commands.

#### HandleReadCommands

`HandleReadCommands(deviceName string, protocols map[string]models.ProtocolProperties, reqs []sdkModels.CommandRequest) ([]*sdkModels.CommandValue, error)`

This interface processes the collection of read requests passed in`reqs` for the specified device `deviceName`. 
It returns a collection of `CommandValues` which contain the device reading details it collected for each read request. 
These `CommandValues` are transformed in to Event/Readings and published to the EdgeX MessageBus by the Device SDK.

An example implementation can be found in the Device SDK's example [Simple Driver](https://github.com/edgexfoundry/device-sdk-go/blob/{{edgexversion}}/example/driver/simpledriver.go)

#### HandleWriteCommands

`HandleWriteCommands(deviceName string, protocols map[string]models.ProtocolProperties, reqs []sdkModels.CommandRequest, params []*sdkModels.CommandValue) error`

This interface processes the collection of write requests passed in`reqs` for the specified device `deviceName`. 
It writes the data found in `params` to the device's resources specified in `reqs`.

An example implementation can be found in the Device SDK's example [Simple Driver](https://github.com/edgexfoundry/device-sdk-go/blob/{{edgexversion}}/example/driver/simpledriver.go)

## ExtendedProtocolDriver Interface

This interface builds upon the existing `ProtocolDriver` interface to provide enhanced features and capabilities without disrupting or breaking existing implementations.

```go
type ExtendedProtocolDriver interface {
	ProfileScan(req requests.ProfileScanRequest) (model.DeviceProfile, error)
	StopDeviceDiscovery(options map[string]any)
	StopProfileScan(deviceName string, options map[string]any)
}
```

### Device

The interfaces in this section deal with devices that the devices service manages

#### ProfileScan

`ProfileScan(req requests.ProfileScanRequest) (model.DeviceProfile, error)`

This interface triggers protocol specific device to discover device profile.
The resulting device profile will be added to the core-metadata and associated with the device.

An example implementation can be found in the Device SDK's example [Simple Driver](https://github.com/edgexfoundry/device-sdk-go/blob/{{edgexversion}}/example/driver/simpledriver.go)

#### StopDeviceDiscovery

`StopDeviceDiscovery(options map[string]any)`

This interface is called when there is a desire to stop the ongoing device discovery process.
It accepts a `map[string]any` as options, which can be used to provide additional parameters for stopping the process.

An example implementation can be found in the Device SDK's example [Simple Driver](https://github.com/edgexfoundry/device-sdk-go/blob/{{edgexversion}}/example/driver/simpledriver.go)

#### StopProfileScan

`StopProfileScan(deviceName string, options map[string]any)`

This interface is called when there is a desire to stop the ongoing device profile scan process for a specific device.
It accepts a `map[string]any` as options, which can be used to provide additional parameters for stopping the process.

An example implementation can be found in the Device SDK's example [Simple Driver](https://github.com/edgexfoundry/device-sdk-go/blob/{{edgexversion}}/example/driver/simpledriver.go)
