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
      [
        {
          "name": "Parameter name",
          "description": "(optional) description of what the parameter controls",
          "type": "Any of the existing EdgeX data types",
          "defaultValue": "(optional) value to use if param is not supplied",
          "maximum": "(optional) for numerics, maximum allowed value",
          "minimum": "(optional) for numerics, minimum allowed value"
        }
      ],
      "returnValues":
      [
        {
          "name": "Name of returned value",
          "description": "(optional) description of what the value indicates",
          "type": "Any of the existing EdgeX data types"
        }
      ]
    }
  ]
}
```

Note: the `attributes` structure is analagous to `attributes` in a `deviceResource`. Each device service should document and implement a scheme of required attributes that will allow for selection of the relevant function.

**Define MessageBus topics on which function call requests and replies are to be made**

These follow the style of messagebus usage set out in the North-South messaging ADR.

`edgex/request/function/[device-service-name]/[device-name]`

The payload for messages on these topics should be of the form
```
{
  "correlation-id": "1dbbd344-c9f6-4714-8c89-91c1d5b11a90",
  "deviceName": "device1",
  "function": "functionname",
  "request":
  {
    "requestId": "184b894f-a7b7-4d6c-b400-99961d462419",
    "parameter1": "37",
    "parameter2": "0"
  }
}

```

`edgex/response/function/[device-service-name]/[device-name]`

The device service will provide responses to function calls on this topic. The payload will be

```
{
  "correlation-id": "1dbbd344-c9f6-4714-8c89-91c1d5b11a90",
  "response":
  {
    "requestId": "184b894f-a7b7-4d6c-b400-99961d462419",
    "statusCode": 0,
    "returnVal1": "true"
  }
}
```

or if a call fails

```
{
  "correlation-id": "1dbbd344-c9f6-4714-8c89-91c1d5b11a90",
  "response":
  {
    "requestId": "184b894f-a7b7-4d6c-b400-99961d462419",
    "statusCode": (nonzero),
    "message": "Message indicating the nature of the failure"
  }
}
```

*Returned status codes*

| Status | Meaning
|--------|--------
| 0      | The operation was successful
| 1      | Request message format error
| 2      | Parameters were missing, out of range or non-parsable
| 3      | The Device is DOWN or DISABLED (OperatingState / AdminState)
| 4      | No such device or function
| 100+   | Implementation-specific errors, defined for each Device Service

*Configuration*

The topic prefixes `edgex/request/function` and `edgex/response/function` will be configurable in the device services.

**Device SDK enhancement**

The device SDKs will handle the messagebus communcations and parameter marshalling. The generic errors defined above may be detected in this SDK code. The SDKs will define APIs for the individual device services to implement the function invocations.

**Command service enhancement**

The core-command service to be extended to provide access to device functions as it does for device readings and settings.

## References

* [ADR 0023-North-South-Messaging](https://github.com/edgexfoundry/edgex-docs/blob/master/docs_src/design/adr/0023-North-South-Messaging.md)
