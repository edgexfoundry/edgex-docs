# Device Service Filters

## Status

### Proposed

- design for Hanoi
- implementation for Ireland

## Context

In EdgeX today, sensor/device data collected can be "filtered" by [application services](../../../microservices/application/ApplicationServices.md) before being exported or sent to some [north side](../../../general/Definitions.md#south-and-north-side) application or system. Built-in application service functions (available through the app services SDK) allow EdgeX event/reading objects to be filtered by device name or by device resource name.  That is, event/readings can be filtered by:

- which device sent the event/reading (as determined by the Event device property).
- the classification or origin (such as temperature or humidity) of data produced by the device as determined by the Reading's name property (which used to be the value descriptor and now refers to the device resource name).

### Two Levels of Device Service Filtering

There are potentially two places where "filtering" in a device service could be useful.  

- One (Sensor Data Filter) - after the device service has communicated with the sensor or device to get sensor values (but before the service creates `Event/Reading` objects and pushes those to core data).  A sensor data filter would allow the device service to essentially ignore some of the raw sensed data.  This would allow for some device service optimization in that the device service would not have perform type transformations and creation of event/reading objects if the data can be eliminated at this early stage.  This first level filtering would, **if put in place**, likely occur in code associated with the read command gets done by the `ProtocolDriver`.
- Two (Reading Filter) - after the sensor data has been collected and read and put into `Event/Reading` objects, there is a desire to filter some of the `Readings` based on the `Reading` values or `Reading` name (which is the device resource name and formerly the value descriptor name) or some combination of value and name.

At this time, **this design only addresses the need for the second filter (Reading Filter)**.  At the time of this writing, no applicable use case has yet to be defined to warrant the Sensor Data Filter.

### Reading Filters
Reading filters will allow, not unlike application service filter functions today, to have `Readings` in an `Event` to be removed if:

- the value was outside or inside some range, or the value was greater than, less than or equal to some value
    - based on the `Reading` value (numeric) of a `Reading` outside a specified range (min/max) described in the device profile for a device resource.  Thus avoiding sending in outlier or jittery data `Readings` that could negatively effect analytics.
    - based on the `Reading` value (numeric) equal to or near (with in some specified range) the last reading.  This allows a device service to reduce sending in `Event/Readings` that do not represent any significant change.  This differs from the already implemented onChangeOnly in that it is filtering `Readings` within a specified degree of change.
- the value was the same as some or not the same as some specified value or values (for strings, boolean and other non-numeric values)
- the name (the device resource name which used to be the value descriptor) matched a particular value; in other words match `temperature` or `humidity` as example device resources.

Unlike application services, there is not a need to filter on a device name (or identifier).  Simply disable the device in the device service if all `Event/Readings` are to be stopped for the device.

In the case that all `Readings` of an `Event` are filtered, it is assumed the entire `Event` is deemed to be worthless and not sent to core data by the device service.  If only some `Readings` from and `Event` are filtered, the `Event` minus the filtered `Readings` would be sent to core data.

### Design / Architecture

A new function interface shall be defined that, when implemented, performs a Reading Filter operation.  A ReadingFilter function would take a parameter (an `Event` containing readings), check whether the `Readings` of the `Event` match on the filtering configuration (see below) and if they do then remove them from the `Event`.  The ReadingFilter function would return the `Event` object (minus filtered `Readings`) or `nil` if the `Event` held no more `Readings`.  Pseudo code for the generic function is provided below.

``` go
func (f Filter) ReadingFilter(lc logger.LoggingClient, event *models.Event) (*models.Event, error) {
    // depending on impl; filtering for values in/out of a range, >, <, =, same, not same, from a particular name (device resource), etc.
    if (len(event.Reading )) > 0)
        return event
    else
        return nil
}
```

Based on current needs/use cases, implementations of the function interface could include the following filter functions:

``` go
func (f Filter) FilterByValueInRange (lc logger.LoggingClient, event *models.Event) (*models.Event, error) {}

func (f Filter) FilterByValueOutRange (lc logger.LoggingClient, event *models.Event) (*models.Event, error) {}

func (f Filter) FilterByValueEqual (lc logger.LoggingClient, event *models.Event) (*models.Event, error) {}

func (f Filter) FilterByValueNotEqual (lc logger.LoggingClient, event *models.Event) (*models.Event, error) {}

func (f Filter) FilterByResourceNamesMatch (lc logger.LoggingClient, event *models.Event) (*models.Event, error) {}
```

!!! Note
    The app functions SDK comes with `FilterByDeviceName` and `FilterByResourceName` functions today. The FilterByResourceName would behave similarly to FilterByResourceNameMatch.

    The Filter structure houses the configuration parameters for which the filter functions work and filter on.

A NewFilter function creates, initializes and returns a new instance of the filter based on the configuration provided.

``` go
func NewReadingNameFilter(filterValues []string) Filter {
    return Filter{FilterValues: filterValues}
}
```

### Sharing filter functions

If one were to explore the filtering functions in the app functions SDK [filter.go](https://github.com/edgexfoundry/app-functions-sdk-go/blob/master/pkg/transforms/filter.go) (both `FilterByDeviceName` and `FilterByValueDescriptor`), the filters operate on the `Event` model object and return the same objects (`Event` or nil).  Ideally, since both app services and device services generally share the same interface model (from `go-mod-core-contracts`), it would be the desire to share the same filter functions functions between SDKs and associated services.

Decisions on how to do this in Go - whether by shared module for example - is left as an implementation detail.  C needs are likely to be handled in the SDK directly.

#### Additional Design Considerations

As Device Services do not have the concept of a functions pipeline like application services do, consideration must be given as to how and where to:

- provide configuration to specify which filter functions to invoke
- create the filter
- invoke the filtering functions

At this time, custom filters will not be supported as the custom filters would not be known by the SDK and therefore could not be specified in configuration.  This is consistent with the app functions SDK and filtering.

#### Function Inflection Point

When instructed to "get" new readings, the function [`execReadDeviceResource`](https://github.com/edgexfoundry/device-sdk-go/blob/0bbcb663a9153978e7e9ef8c297d5988e58906d0/internal/handler/command.go) is called which subsequently calls on the the device service driver's `HandleReadCommands` function to get the latest sensor values from the device.  The driver's `HandleReadCommands` returns the sensor reading data (via array of CommandValues) to be put into an event.

After receiving the `CommandValues` the `execReadDeviceResource` function calls the `cvsToEvent` function convert the `CommandValues` into and `Event/Reading` objects (from `go-mod-core-contracts`) and returns this model to be sent via REST to core data by the rest of the SDK.

It is precisely after the convert to `Event/Reading` objects and before returning that result in `common.SendEvent` (in utils.go) function that the device service should invoke the required filter functions.

Events containing binary values (event.HasBinaryValue), will not be filtered.  Future releases may include binary value filters.

!!! TODO
    *Where and how would this work for Async events? Need help from the DS team.*

    *Are the Go and C SDKs similar enough to use this design?*

    *Do we care about function order?*

#### Setting Filter Function and Configuration

When filter functions are shared (or appear to be doing the same type of work) between SDKs, the configuration of the similar filter functions should also look similar.  The app functions SDK configuration model for filters should therefore be followed.

While device services do not have pipelines, the inclusion and configuration of filters for device services should have a similar look (to provide symmetry with app services). The configuration has to provide the functions required and parameters to make the functions work - even though the association to a pipeline is not required.  Below is the common app service configuration as it relates to filters:

``` toml
[Writable.Pipeline]
    ExecutionOrder = "FilterByDeviceName, TransformToXML, SetOutputData"
    [Writable.Pipeline.Functions.FilterByDeviceName]
    [Writable.Pipeline.Functions.FilterByDeviceName.Parameters]
        DeviceNames = "Random-Float-Device,Random-Integer-Device"
        FilterOut = "false"
```

Suggested and hypothetical configuration for the device service reading filters should look something like that below.

``` toml
[Writable.Filters]
    ExecutionOrder = "FilterByValueInRange, FilterByResourceNamesMatch"
    [Writable.Filter.Functions.FilterByResourceNamesMatch]
        [Writable.Filter.Functions.FilterByResourceNamesMatch.Parameters]
            DeviceNames = "Random-Float-Device,Random-Integer-Device"
            FilterOut = "false"
    [Writable.Filter.Functions.FilterByValueInRange]
        [Writable.Filter.Functions.FilterByValueInRange.Parameters]
            Min = 100
            Max = 200
```

## Decision

*To be determined*

## Consequences

This design does not take into account potential changes found with the V2 API.

## References

