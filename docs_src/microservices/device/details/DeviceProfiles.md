---
title: Device Service - Device Profiles
---

# Device Service - Device Profiles

The device profile describes a type of [device](../../../general/Definitions.md#device) within the EdgeX system. 
Each device managed by a device service has an association with a device profile,
which defines that device type in terms of the operations which it supports.

Typically, device profiles are loaded from file by the Device Service and pushed to Core Metadata for storage on first start. 
Once stored in Core Metadata, the device profiles are loaded from Core Metadata on subsequent starts.

!!! warning
    Editing the local device profile after Device Service has started will not impact the actual device profile being used. The old version must first be removed from Core Metadata and then the Device Service must be restarted to push the new version to Core Metadata.

Device profiles can also be manually Added/Updated/Deleted using Core Metadata's Device Profile [REST API](../../core/metadata/ApiReference.md)

## Device Profile

A device profile consists of the following fields.

| Field Name      | Type                    | Required? | Description                                                |
|:----------------|:------------------------|:----------|:-----------------------------------------------------------|
| name            | String                  | Y         | Must be unique in the EdgeX deployment.                    |
| description     | String                  | N         | Description of the Device Profile                          |
| manufacturer    | String                  | N         | Manufacturer of the device described by the Device Profile |
| model           | String                  | N         | Model of the device(s) described by the Device Profile     |
| labels          | Array of String         | N         | Free form labels for querying device profiles              |
| deviceResources | Array of DeviceResource | Y         | See [Device Resources](#device-resources) below            |
| deviceCommands  | Array of DeviceCommand  | N         | See [Device Commands](#device-commands) below              |

### Device Resources

A device resource specifies a sensor value within a device that may be read
from or written to either individually or as part of a device command. It has a
name for identification and a description for informational purposes.

The device resource consists of the following fields:

| Field Name  | Type                 | Required? | Notes                                                                      |
|:------------|:---------------------|:----------|:---------------------------------------------------------------------------|
| name        | String               | Y         | Must be unique in the EdgeX deployment.                                    |
| description | String               | N         | Description of the device resource                                         |
| isHidden    | Bool                 | N         | Hide the device resource as command via the Command Service, default false |
| tags        | String-Interface Map | N         | User define collection of tags                                             |
| attributes  | String-Interface Map | N         | See [Resource Attributes](#resource-attributes) below                      |
| properties  | ResourceProperties   | Y         | See [Resource Properties](#resource-properties) below                      |

#### Resource Attributes

The `attributes` in a device resource are the device service specific parameters
required to access the particular value on the device. Each device service implementation
will have its own set of named values that are required here, for example a
BACnet device service may need an object identifier and a property identifier
whereas a Bluetooth device service could use a UUID to identify a value.

!!! example - "Example Resource Attributes from Device ONVIF Camera"
    ```yaml
        attributes:
          service: "Device"
          getFunction: "GetDNS"
          setFunction: "SetDNS"
    ```

#### Resource Properties 

The `properties` of a device resource describe the value and optional simple processing to be performed on it. 

The resource properties consists of the following fields:

| Field Name   | Type           | Required? | Notes                                                                                                                                                                                                                                                                                                                                                                              |
|:-------------|:---------------|:----------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| valueType    | Enum           | Y         | The data type of the value. Supported types are: `Uint8`, `Uint16`, `Uint32`, `Uint64`, `Int8`, `Int16`, `Int32`, `Int64`, `Float32`, `Float64`, `Bool`, `String`, `Binary`, `Object`, `Uint8Array`, `Uint16Array`, `Uint32Array`, `Uint64Array`, `Int8Array`, `Int16Array`, `Int32Array`, `Int64Array`, `Float32Array`, `Float64Array`, `BoolArray`                               |
| readWrite    | Enum           | Y         | Indicates whether the value is readable or writable or both. `R` - Read only , `W` - Write only, `RW` - Read or Write                                                                                                                                                                                                                                                              |
| units        | String         | N         | Developer defined units of value such as secs, mins, etc                                                                                                                                                                                                                                                                                                                           |
| minimum      | Float64        | N         | Minimum value the resource value can be set to. Error if SET command value out of minimum range                                                                                                                                                                                                                                                                                    |
| maximum      | Float64        | N         | Maximum value the resource value can be set to. Error if SET command value out of maximum range                                                                                                                                                                                                                                                                                    |
| defaultValue | String         | N         | Default value to use when no value is present for a set command. If present, should be compatible with the valueType field                                                                                                                                                                                                                                                         |
| mask         | Uint64         | N         | A binary mask which will be applied to an integer reading. Only valid when valueType is one of the unsigned integer types                                                                                                                                                                                                                                                          |
| shift        | Int64          | N         | A number of bits by which an integer reading will be shifted right. Only valid when valueType is one of the unsigned integer types                                                                                                                                                                                                                                                 |
| scale        | Float64        | N         | A factor by which to multiply a reading before it is returned. Only valid when valueType is one of the integer or float types                                                                                                                                                                                                                                                      |
| offset       | Float64        | N         | A value to be added to a reading before it is returned. Only valid when valueType is one of the integer or float types                                                                                                                                                                                                                                                             |
| base         | Float64        | N         | A value to be raised to the power of the raw reading before it is returned. Only valid when valueType is one of the integer or float types                                                                                                                                                                                                                                         |
| assertion    | String         | N         | A string value to which a reading (after processing) is compared. If the reading is not the same as the assertion value, the device's operating state will be set to disabled. This can be useful for health checks.                                                                                                                                                               |
| mediaType    | String         | N         | A string indicating the content type of the `Binary` value. Required when valueType is `Binary`.                                                                                                                                                                                                                                                                                   |
| optional     | String-Any Map | N         | Optional mapping for developer use                                                                                                                                                                                                                                                                                                                                                 |

The optional processing defined by base, scale, offset, mask and shift is applied in
that order. This is done within the SDK. A reverse transformation is applied
by the SDK to incoming data on set operations (NB mask transforms on set are NYI)

### Device Commands

Device Commands define access to multiple resources simultaneously. Each named device command should contain multiple `resource operations`. 
A device command with a single resource operation adds no value over the implicit device command created by the SDK for the same device resource.

Device commands may be useful when readings are logically related, for example with a 3-axis accelerometer it is helpful to read all axes together.

Each device command consists of the following fields:

| Field Name         | Type                       | Required? | Notes                                                                                                                                                                                                                |
|:-------------------|:---------------------------|:----------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name               | String                     | Y         | Must be unique in this profile.                                                                                                                                                                                      |
| isHidden           | Bool                       | N         | Hide the Device Command for use via Command Service, default false                                                                                                                                                   |
| readWrite          | Enum                       | Y         | Indicates whether the command is readable or writable or both. `R` - Read only , `W` - Write only, `RW` - Read or Write. Resources' readWrite included in the command must be consistent with the value chosen here. |
| resourceOperations | Array of ResourceOperation | Y         | see [Resource Operation](#resource-operation) below                                                                                                                                                                  |

#### Resource Operation

A resource operation consists of the following fields:

| Field Name     | Type              | Required? | Notes                                                                             |
|:---------------|:------------------|:----------|:----------------------------------------------------------------------------------|
| deviceResource | String            | Y         | Must name a Device Resource in this profile                                       |
| defaultValue   | String            | N         | If present, should be compatible with the Type field of the named Device Resource |
| mappings       | String-String Map | N         | Map the GET resourceOperation value to another string value                       |

## REST Command endpoints

The commands endpoints are implicitly created on the service for each device resource and each device command specified in the device profile.
See the GET and SET Device Command APIs in the [Device Service API Reference](../ApiReference.md) for more details.

## Example Device Profiles

A good starting point example device profile is the [Simple Driver profile](https://github.com/edgexfoundry/device-sdk-go/blob/{{edgexversion}}/example/cmd/device-simple/res/profiles/Simple-Driver.yaml) from the Go Device SDK Device Simple example service.

The Device Modbus device profile [here](https://github.com/edgexfoundry/device-modbus-go/blob/{{edgexversion}}/cmd/res/profiles/modbus.test.device.profile.yml) is a good example of using `attributes` to define how to access the resource value on the device.

