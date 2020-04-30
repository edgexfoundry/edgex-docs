# Device Profile Reference

This chapter details the structure of a Device Profile and allowable values for
its fields.

Device Profile
--------------

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
Name | String | Y | Must be unique in the EdgeX deployment
Manufacturer | String | N |
Model | String | N |
Labels | Array of String | N |
DeviceResources | Array of DeviceResource | Y |
DeviceCommands  | Array of DeviceCommand | N |
CoreCommands | Array of CoreCommand | N |

DeviceResource
--------------

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
Name | String | Y | Must be unique in the EdgeX deployment
Tag | String | N
Attributes | String-String Map | Y | Each Device Service should define required and optional keys
Properties | ProfileProperty | Y |

ProfileProperty
---------------

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
Value | PropertyValue | Y |
Units | Units | N |

PropertyValue
-------------

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
Type | Enum | Y | `uint8`, `uint16`, `uint32`, `uint64`, `int8`, `int16`, `int32`, `int64`, `float32`, `float64`, `bool`, `string`, `binary`, `uint8array`, `uint16array`, `uint32array`, `uint64array`, `int8array`, `int16array`, `int32array`, `int64array`, `float32array`, `float64array`, `boolarray`
ReadWrite | Enum | Y | `R`, `W`, `RW`
DefaultValue | String | N | If present, should be compatible with the Type field
Mask | Unsigned Int | N | Only valid where Type is one of the integer types
Shift | Unsigned Int | N | Only valid where Type is one of the integer types
Scale | Int or Float | N | Only valid where Type is one of the integer or float types
Offset | Int or Float | N | Only valid where Type is one of the integer or float types
Base | Int or Float | N | Only valid where Type is one of the integer or float types
Assertion | String | N |
FloatEncoding | Enum | N | `base64`, `eNotation` - Only valid where Type is one of the float types
MediaType | String | N | Only valid where Type is Binary

Units
-----

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
DefaultValue | String | Y |

DeviceCommand
-------------

(NB represented in Go by `ProfileResource`)

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
Name | String | Y | Must be unique in this profile. May have the same name as a DeviceResource but this will make the DeviceResource not accessible individually. Such a configuration is only recommended if Mappings are used: see below.
Get | Array of ResourceOperation | N | At least one of Get and Set must be present
Set | Array of ResourceOperation | N | At least one of Get and Set must be present

ResourceOperation
-----------------

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
DeviceResource | String | Y | Must name a DeviceResource in this profile
Parameter | String | N | If present, should be compatible with the Type field of the named DeviceResource
Mappings | String-String Map | N | Only valid where the Type of the named DeviceResource is String


CoreCommand
-----------

(NB represented in Go by `Command`)

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
Name | String | Y | Must name a DeviceCommand or a DeviceResource in this profile
Get | GetCommand | See note | At least one of Get and Put must be present
Put | PutCommand | See note | At least one of Get and Put must be present

GetCommand
----------

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
Path | String | Y | Must be `/api/v1/device/{deviceId}/XXX` where XXX is the name of the command
Responses | Array of Response | Y |

PutCommand
----------

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
Path | String | Y | Must be `/api/v1/device/{deviceId}/XXX` where XXX is the name of the command
Responses | Array of Response | Y |
ParameterNames | Array of String | Y | Should correspond to the DeviceResource names associated with this Command

Response
--------

Field Name | Type | Required? | Notes
:--- | :--- | :--- | :---
Code | Unsigned Int | Y | Should be a valid HTTP response code
Description | String | N |
ExpectedValues | Array of String | Y | For Get commands with success (2xx) Code, should correspond to the DeviceResource names associated with this command. For failing Get commands and Put commands, should be an empty array.
