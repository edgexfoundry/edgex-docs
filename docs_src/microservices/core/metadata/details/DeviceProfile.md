---
title: Core Metadata - Device Profile
---

# Core Metadata - Device Profile

The device profile describes a type of [device](../../../../general/Definitions.md#device) within the EdgeX system. Each
device managed by a device service has an association with a device profile,
which defines that device type in terms of the operations which it supports.

For a full list of device profile fields and their required values see the [device profile reference](#device-profile-reference).

For a detailed look at the device profile model and all its properties, see the [metadata device profile data model](../GettingStarted.md#data-models).

Identification
--------------

The profile contains various identification fields. The `Name` field is required and must be unique in an EdgeX deployment. Other fields are optional - they are not used by device services but may be populated for informational purposes:

* Description
* Manufacturer
* Model
* Labels

DeviceResources
---------------

A deviceResource specifies a sensor value within a device that may be read
from or written to either individually or as part of a deviceCommand. It has a
name for identification and a description for informational purposes.

The device service allows access to deviceResources via its `device`
REST endpoint.

The `Attributes` in a deviceResource are the device-service-specific parameters
required to access the particular value. Each device service implementation
will have its own set of named values that are required here, for example a
BACnet device service may need an Object Identifier and a Property Identifier
whereas a Bluetooth device service could use a UUID to identify a value.

The `Properties` of a deviceResource describe the value and optionally request
some simple processing to be performed on it. The following fields are available:

* valueType - Required. The data type of the value. Supported types are `Bool`,
`Int8` - `Int64`, `Uint8` - `Uint64`, `Float32`, `Float64`, `String`, `Binary`,
`Object` and arrays of the primitive types (ints, floats, bool). Arrays are specified
as eg. `Float32Array`, `BoolArray` etc.
* readWrite - `R`, `RW`, or `W` indicating whether the value is readable or
writable.
* units - indicate the units of the value, eg Amperes, degrees C, etc.
* minimum - minimum value a SET command is allowed, out of range will result in error.
* maximum - maximum value a SET command is allowed, out of range will result in error.
* defaultValue - a value used for SET command which do not specify one.
* assertion - a string value to which a reading (after processing) is compared.
 If the reading is not the same as the assertion value, the device's operating
state will be set to disable. This can be useful for health checks.
* base - a value to be raised to the power of the raw reading before it is returned.
* scale - a factor by which to multiply a reading before it is returned.
* offset - a value to be added to a reading before it is returned.
* mask - a binary mask which will be applied to an integer reading.
* shift - a number of bits by which an integer reading will be shifted right.
* mediaType - a string indicating the format of the `Binary` value.
* optional - a optional properties mapping for the given device resource.

The processing defined by base, scale, offset, mask and shift is applied in
that order. This is done within the SDK. A reverse transformation is applied
by the SDK to incoming data on set operations (NB mask transforms on set are NYI)

DeviceCommands
--------------

DeviceCommands define access to reads and writes for multiple simultaneous
device resources. Each named deviceCommand should contain a number of
`resourceOperations`.

DeviceCommands may be useful when readings are logically related, for example
with a 3-axis accelerometer it is helpful to read all axes together.

A resourceOperation consists of the following properties:

* deviceResource - the name of the deviceResource to access.
* defaultValue - optional, a value that will be used if a SET command does not
specify one.
* mappings - optional, allows readings of String type to be re-mapped.

The device service allows access to deviceCommands via the same `device` REST
endpoint as is used to access deviceResources.

## Device Profile Reference

This chapter details the structure of a Device Profile and allowable values for
its fields.

Device Profile
--------------

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
name | String | Y | Must be unique in the EdgeX deployment. Only allow unreserved characters as defined in https://datatracker.ietf.org/doc/html/rfc3986#section-2.3.
description | String | N |
manufacturer | String | N |
model | String | N |
labels | Array of String | N |
deviceResources | Array of DeviceResource | Y |
deviceCommands  | Array of DeviceCommand | N |

DeviceResource
--------------

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
name | String | Y | Must be unique in the EdgeX deployment. Only allow unreserved characters as defined in https://datatracker.ietf.org/doc/html/rfc3986#section-2.3.
description | String | N |
isHidden | Bool | N | Expose the DeviceResource to Command Service or not, default false
tag | String | N |
attributes | String-Interface Map | N | Each Device Service should define required and optional keys
properties | ResourceProperties | Y |

ResourceProperties
---------------

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
valueType | Enum | Y | `Uint8`, `Uint16`, `Uint32`, `Uint64`, `Int8`, `Int16`, `Int32`, `Int64`, `Float32`, `Float64`, `Bool`, `String`, `Binary`, `Object`, `Uint8Array`, `Uint16Array`, `Uint32Array`, `Uint64Array`, `Int8Array`, `Int16Array`, `Int32Array`, `Int64Array`, `Float32Array`, `Float64Array`, `BoolArray`
readWrite | Enum | Y | `R`, `W`, `RW` 
units | String | N | Developer is open to define units of value
minimum | Float64 | N | Error if SET command value out of minimum range
maximum | Float64 | N | Error if SET command value out of maximum range
defaultValue | String | N | If present, should be compatible with the Type field
mask | Uint64 | N | Only valid where Type is one of the unsigned integer types
shift | Int64 | N | Only valid where Type is one of the unsigned integer types
scale | Float64 | N | Only valid where Type is one of the integer or float types
offset | Float64 | N | Only valid where Type is one of the integer or float types
base | Float64 | N | Only valid where Type is one of the integer or float types
assertion | String | N | String value to which the reading is compared
mediaType | String | N | Only required when valueType is `Binary`
optional | String-Any Map | N | Optional mapping for the given resource

DeviceCommand
-------------

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
name | String | Y | Must be unique in this profile. A DeviceCommand with a single DeviceResource is redundant unless renaming and/or restricting R/W access. For example DeviceResource is RW, but DeviceCommand is read-only. Only allow unreserved characters as defined in https://datatracker.ietf.org/doc/html/rfc3986#section-2.3.
isHidden | Bool | N | Expose the DeviceCommand to Command Service or not, default false
readWrite | Enum | Y | `R`, `W`, `RW`
resourceOperations | Array of ResourceOperation | Y |

ResourceOperation
-----------------

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
deviceResource | String | Y | Must name a DeviceResource in this profile
defaultValue | String | N | If present, should be compatible with the Type field of the named DeviceResource
mappings | String-String Map | N | Map the GET resourceOperation value to another string value
