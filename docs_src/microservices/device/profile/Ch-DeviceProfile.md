# Device Profile

The device profile describes a type of device within the EdgeX system. Each
device managed by a device service has an association with a device profile,
which defines that device type in terms of the operations which it supports.

For a full list of device profile fields and their required values see the [Device Profile Reference](./Ch-DeviceProfileRef.md)

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
some simple processing to be performed on it. Each device resource
is given two properties, `value` and `units`. The following fields are
available in the `value` property:

* type - Required. The data type of the value. Supported types are `bool`,
`int8` - `int64`, `uint8` - `uint64`, `float32`, `float64`, `string`, `binary`
and arrays of the primitive types (ints, floats, bool). Arrays are specified
as eg. `float32array`, `boolarray` etc.
* readWrite - `R`, `RW`, or `W` indicating whether the value is readable or
writable.
* defaultValue - a value used for PUT requests which do not specify one.
* assertion - a string value to which a reading (after processing) is compared.
 If the reading is not the same as the assertion value, the device's operating
state will be set to disbled. This can be useful for health checks.
* base - a value to be raised to the power of the raw reading before it is returned.
* scale - a factor by which to multiply a reading before it is returned.
* offset - a value to be added to a reading before it is returned.
* mask - a binary mask which will be applied to an integer reading.
* shift - a number of bits by which an integer reading will be shifted right.

The processing defined by base, scale, offset, mask and shift is applied in
that order. This is done within the SDK. A reverse transformation is applied
by the SDK to incoming data on set operations (NB mask transforms on set are NYI)

The `units` property is used to indicate the units of the value, eg Amperes,
degrees C, etc. It should have a `defaultValue` that specifies the units.

DeviceCommands
--------------

DeviceCommands define access to reads and writes for multiple simultaneous
device resources. Each named deviceCommand should contain a number of get
and/or set `resourceOperations`, describing the read or write respectively.

DeviceCommands may be useful when readings are logically related, for example
with a 3-axis accelerometer it is helpful to read all axes together.

A resourceOperation consists of the following properties:

* index - a number, used to define an order in which the resource is processed.
and set operations is not supported.
* deviceResource - the name of the deviceResource to access.
* parameter - optional, a value that will be used if a PUT request does not
specify one.
* mappings - optional, allows readings of String type to be re-mapped.

The device service allows access to deviceCommands via the same `device` REST
endpoint as is used to access deviceResources. If a deviceCommand and
deviceResource have the same name, it will be the deviceCommand which is
available.

CoreCommands
------------

CoreCommands specify the commands which are available via the core-command
microservice, for reading and writing to the device. Both deviceResources and
deviceCommands may be represented by coreCommands (the name of the coreCommand
refers to the name of the deviceCommand or deviceResource).

Commands may allow get or put methods (or both). For a get type, the returned
values are specified in the `expectedValues` field, for a put type, the
parameters to be given are specified in `parameterNames`. In either case, the
different http response codes that the service may generate are indicated.

Core Commands may be thought of as defining the outward-facing API for the
device. A typical setup would prevent external access to the device service
itself, so use of the full range of device resources and device commands would
only be available to other components within the EdgeX deployment. Only those
that has corresponding coreCommands would be available externally (via
core-command).
