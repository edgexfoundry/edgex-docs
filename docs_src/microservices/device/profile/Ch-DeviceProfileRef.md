# Device Profile Reference

This chapter details the structure of a Device Profile and allowable values for
its fields.

Device Profile
--------------

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
name | String | Y | Must be unique in the EdgeX deployment. Only allow unreserved characters as defined in https://tools.ietf.org/html/rfc3986#section-2.3.
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
name | String | Y | Must be unique in the EdgeX deployment. Only allow unreserved characters as defined in https://tools.ietf.org/html/rfc3986#section-2.3.
description | String | N |
isHidden | Bool | N | Expose the DeviceResource to Command Service or not, default false
tag | String | N |
attributes | String-Interface Map | N | Each Device Service should define required and optional keys
properties | ResourceProperties | Y |

ResourceProperties
---------------

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
valueType | Enum | Y | `Uint8`, `Uint16`, `Uint32`, `Uint64`, `Int8`, `Int16`, `Int32`, `Int64`, `Float32`, `Float64`, `Bool`, `String`, `Binary`, `Uint8Array`, `Uint16Array`, `Uint32Array`, `Uint64Array`, `Int8Array`, `Int16Array`, `Int32Array`, `Int64Array`, `Float32Array`, `Float64Array`, `BoolArray`
readWrite | Enum | Y | `R`, `W`, `RW` 
units | String | N | Developer is open to define units of value
minimum | String | N | Error if SET command value out of minimum range
maximum | String | N | Error if SET command value out of maximum range
defaultValue | String | N | If present, should be compatible with the Type field
mask | String | N | Only valid where Type is one of the unsigned integer types
shift | String | N | Only valid where Type is one of the unsigned integer types
scale | String | N | Only valid where Type is one of the integer or float types
offset | String | N | Only valid where Type is one of the integer or float types
base | String | N | Only valid where Type is one of the integer or float types
assertion | String | N | String value to which the reading is compared
mediaType | String | N | Only required when valueType is `Binary`

DeviceCommand
-------------

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
name | String | Y | Must be unique in this profile. A DeviceCommand with a single DeviceResource is redundant unless renaming and/or restricting R/W access. For example DeviceResource is RW, but DeviceCommand is read-only. Only allow unreserved characters as defined in https://tools.ietf.org/html/rfc3986#section-2.3.
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
