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
          "type": "Any of the usual EdgeX data types",
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
          "type": "Any of the usual EdgeX data types"
        }
      ]
    }
  ]
}
```

Note: the `attributes` structure is analagous to `attributes` in a `deviceResource`. Each device service should document and implement a scheme of required attributes that will allow for selection of the relevant funtion. The function's `name` is intended for UI and logging purposes and should not be used for actual function selection on the device.

**Define MessageBus topics on which function call requests and replies are to be made**

`edgex/function-calls/device/[profile-name]/[device-name]/[function-name]`

The payload for messages on these topics should be of the form
```
{
  requestId: "184b894f-a7b7-4d6c-b400-99961d462419",
  parameters: { (a map of parameter values keyed by parameter name) }
}
```

The `requestId` may be any string but UUIDs are recommended.

`edgex/function-responses/device/[profile-name]/[device-name]/[function-name]`

The device service will provide responses to function calls on this topic. The payload will be

```
{
  requestId: "184b894f-a7b7-4d6c-b400-99961d462419",
  status: 0,
  returnValues: { (a map of return values keyed by value name) }
}
```

or if a call fails

```
{
  requestId: "184b894f-a7b7-4d6c-b400-99961d462419",
  status: (nonzero),
  errorMessage "Message indicating the nature of the failure"
}
```

*Returned status codes*

| Status | Meaning
|--------|--------
| 0      | The operation was successful
| 1      | Parameters were missing, out of range or non-parsable
| 2      | The Device is DOWN or DISABLED
| 3      | No such device or function
| 100+   | Implementation-specific errors, defined for each Device Service

** The device SDKs will provide an API for the service implementations to implement these operations **

