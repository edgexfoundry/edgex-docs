# Array Datatypes Design

<!--ts-->

- [Status](#status)
- [Context](#context)
- [Decision](#decision)
- [Consequences](#consequences)

<!--te-->

## Status

**Approved**

## Context  

The current data model does not directly provide for devices which provide array data. Small fixed-length arrays may be handled by defining multiple device resources - one for each element - and aggregating them via a resource command. Other array data may be passed using the Binary type. Neither of these approaches is ideal: the binary data is opaque and any service processing it would need specific knowledge to do so, and aggregation presents the device service implementation with a multiple-read request that could in many cases be better handled by a single request.

This design adds arrays of primitives to the range of supported types in EdgeX. It comprises an extension of the DeviceProfile model, and an update to the definition of Reading.

## Decision

### DeviceProfile extension

The permitted values of the `Type` field in `PropertyValue` are extended to include:
  "BoolArray", "Uint8Array", "Uint16Array", "Uint32Array", "Uint64Array", "Int8Array", Int16Array", "Int32Array", "Int64Array", "Float32Array", "Float64Array"

### Readings

In the API (v1 and v2), `Reading.Value` is a string representation of the data. If this is maintained, the representation for Array types will follow the JSON array syntax, ie `["value1", "value2", ...]`

## Consequences

Any service which processes Readings will need to be reworked to account for the new Reading type.

### Device Service considerations

The API used for interfacing between device SDKs and devices service implementations contains a local representation of reading values. This will need to be updated in line with the changes outlined here. For C, this will involve an extension of the existing union type. For Go, additional fields may be added to the `CommandValue` structure.

Processing of numeric data in the device service, ie `offset`, `scale` etc will not be applied to the values in an array.
