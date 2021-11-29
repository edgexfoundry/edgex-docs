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

1. Add a new section to device profiles describing functions

{
  "deviceFunctions":
  [
    {
      "name": "Name by which the function is accessed",
      "description": "Readable description of the function",
      "attributes": { device-specific parameters which select this function },
      "parameters":
      {
        "in":
        [
          {
            "name": "Parameter name",
            "description": "description of what the parameter controls",
            "type": "Any of the usual EdgeX data types"
          }
        ],
        "out":
        [
          {
            "name": "Parameter name",
            "description": "description of what the parameter controls",
            "type": "Any of the usual EdgeX data types"
          }
        ]
      }
    }
  ]
}

2. Add a REST endpoint to the device service for performing functions

api/v2/device-funtion/<device-name>/<function-name>

This shold accept POST requests with parameters sent in a JSON (or CBOR) payload

A successful invocation should return HTTP 200 with the out parameters in JSON
or CBOR format.

Returnable errors should be
BAD REQUEST: parameters were missing or wrong type
INTERNAL SERVER ERROR: the DS implementation was unable to fulfill the request
NOT FOUND: no such device, or no such function
LOCKED: device or service is locked or down (adminstate, operating state)

3. Add a REST endpoint to core-command for performing functions
