# Invoking Device Functions
 

## Status

**Draft**

## Context
This ADR presents a mechanism for invoking functions on a device.

## Existing Behavior

Device access in EdgeX is focussed on 'Readings' and 'Settings'. A device may
present values which are readable, representing some measurement or status,
such as a temperature or vibration reading. Also a setting such as a the
required speed of a fan motor may be written to and read back.

What is not supported directly is 'Functions', where a device may be commanded
to do something. Examples could include perform a self-test, go into standby
mode for an hour, invalidate an access key.

While such operations may modelled using virtual resources in a device profile,
this is unintuitive.

## Decision

**Add a new section to device profiles describing functions**

```
{
  "deviceFunctions":
  [
    {
      "name": "Name by which the function is accessed",
      "description": "Readable description of the function",
      "attributes": { device-service-specific attributes which select this function },
      "parameters":
      {
        "in":
        [
          {
            "name": "Parameter name",
            "description": "(optional) description of what the parameter controls",
            "type": "Any of the usual EdgeX data types",
            "defaultValue": "(optional) value to use if param is not supplied",
            "maximum": "(optional) for numerics, maximum allowed value",
            "minimum": "(optional) for numerics, minimum allowed value"
          }
        ],
        "out":
        [
          {
            "name": "Name of returned value",
            "description": "(optional) description of what the value indicates",
            "type": "Any of the usual EdgeX data types"
          }
        ]
      }
    }
  ]
}
```

Note: the `attributes` structure is analagous to `attributes` in a `deviceResource`. Each device service should document and implement a scheme of required attributes that will allow for selection of the relevant funtion. The function's `name` is intended for UI and logging purposes and should not be used for actual function selection on the device.

**Add a REST endpoint to the device service for performing functions**

`api/v2/device-funtion/<device-name>/<function-name>`

This shold accept POST requests with parameters sent in a JSON (or CBOR) payload

A successful invocation should return HTTP 200 with the out values in JSON
or CBOR format.

Returnable errors should be

* BAD REQUEST: parameters were missing, wrong type, or out-of-range
* INTERNAL SERVER ERROR: the DS implementation was unable to fulfill the request
* NOT FOUND: no such device, or no such function
* LOCKED: device or service is locked or down (adminstate, operating state)

**Add a REST endpoint to core-command for performing functions**
