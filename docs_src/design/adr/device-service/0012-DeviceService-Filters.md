# Device Service Filters

## Status

### Proposed

- design for Hanoi
- implementation for Ireland

## Context

In EdgeX today, sensor/device data collected can be "filtered" by [application services](../../../microservices/application/ApplicationServices.md) before being exported or sent to some [north side](../../../general/Definitions.md#south-and-north-side) application or system. Built-in application service functions (available through the app services SDK) allow EdgeX event/reading objects to be filtered by device name or by value descriptor type.  That is, event/readings can be filtered by:

- which device sent the event/reading (as determined by the device name in the event/readings)
- the category (such as temperature or humidity) of data as determined by the value descriptor.

*With value descriptor's deprecation, what will the app function SDK offer for filtering?*

### Filter by device name and value descriptor nearer collection

While application service filters help to limit the amount of data sent north, those events and readings are still collected, stored, processed by the EdgeX micro services, potentially resulting in wasted resources processing unneeded data.

Therefore, there is a desire to help filter data at the device service level - thereby limiting the amount of sensor data that is captured, stored and processed as well as sent north.

In the first stage of device service filtering, it is desired that the filter by device name and value descriptor be offered in all device services (via the SDK).  The filtering of event/readings should be accomplished just before the event/readings are sent to core data or (or put on the message bus in future implementations where DS message application services).  See Design below for more details.

### Sharing filter functions

If one were to explore the filtering functions in the app functions SDK [filter.go](https://github.com/edgexfoundry/app-functions-sdk-go/blob/master/pkg/transforms/filter.go) (both FilterByDeviceName and FilterByValueDescriptor), the filters operate on a simple event model object.  Ideally, since both app services and device services share the event model (from go-mod-core-contracts), it would be the desire to share filter functions to some degree between SDKs.

### Future Filters

There are additional characteristics by which device services may want to filter event/readings.  Since the device service originates the event/reading, there may be circumstances where by the event/reading is considered invalid or not valuable enough to even process through the rest of EdgeX.  So, in addition to filtering by particular devices or value descriptor, device services may in the future offer filters:

- based on the reading value (numeric) of a reading outside a specified range (min/max) described in the device profile for a device resource.  Thus avoiding sending in outlier or jittery data readings that could negatively effect analytics.
- based on the reading value (numeric) equal to or near (with in some specified range) the last reading.  This allows a device service to reduce sending in event/readings that do not represent any significant change.  This filter would require that the device service maintains some sort of cache of past readings.

If the concept of shared functions is achieved, there is no reason why these functions could not be reusable in application service pipelines as well.

### Design Considerations

#### Pipeline Nada

As Device Services do not have the concept of a functions pipeline like application services do, consideration must be given as to how and where to:

- invoke the filtering functions
- provide configuration to specify which filter functions to invoke

#### Function Inflection Point

When instructed to "get" new readings, the function [execReadDeviceResource](https://github.com/edgexfoundry/device-sdk-go/blob/0bbcb663a9153978e7e9ef8c297d5988e58906d0/internal/handler/command.go) is called which subsequently calls on the the device service driver's HandleReadCommands function to get the latest sensor values from the device.  The driver's HandleReadCommands returns the sensor reading data (via array of CommandValues) to be put into an event.

After receiving the CommandValues the execReadDeviceResource function calls the cvsToEvent function convert the CommandValues into and event/reading objects (from go-mod-core-contracts) and returns this model to be sent via REST to core data by the rest of the SDK.

It is precisely after the convert to event/readings and before returning that result in execReadDeviceResource function that the device service should invoke the required filter functions.

*Are the Go and C SDKs similar enough to use this design?*
*Do we care about function order?*

#### Function Configuration

While device services do not have pipelines, the inclusion and configuration of filters for device services could take on a similar look (to provide symmetry with app services)

``` toml
[Writable.Functions.FilterByDeviceName]
    [Writable.Functions.FilterByDeviceName.Parameters]
    DeviceNames = "Random-Float-Device,Random-Integer-Device"
    FilterOut = "false"
[Writable.Functions.FilterByValueDescriptor]
    [Writable.Functions.FilterByValueDescriptor.Parameters]
    ValueDescriptors = "RandomValue_Int8, RandomValue_Int64"
    FilterOut = "false"
```

## Decision

*To be determined*

## Consequences

This design does not take into account potential changes found with the V2 API.

## References
