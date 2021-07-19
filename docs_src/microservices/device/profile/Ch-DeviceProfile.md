# Device Profile

The device profile describes a type of [device](../../../general/Definitions.md#device) within the EdgeX system. Each
device managed by a device service has an association with a device profile,
which defines that device type in terms of the operations which it supports.

For a full list of device profile fields and their required values see the [device profile reference](./Ch-DeviceProfileRef.md).

For a detailed look at the device profile model and all its properties, see the [metadata device profile data model](../../core/metadata/Ch-Metadata.md#data-models).

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

* valueType - Required. The data type of the value. Supported types are `bool`,
`int8` - `int64`, `uint8` - `uint64`, `float32`, `float64`, `string`, `binary`
and arrays of the primitive types (ints, floats, bool). Arrays are specified
as eg. `float32array`, `boolarray` etc.
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


!!! edgey "EdgeX 2.0"
For the EdgeX 2.0 (Ireland) release coreCommands section is removed and both deviceResources and deviceCommands are available via the Core Command Service by default.
Set `isHidden` field to true under deviceResource or deviceCommand to disable the outward-facing API.
