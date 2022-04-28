# Device Service Filters

## Status

** Approved ** (by TSC vote on 3/15/21)

- design (initially) for Hanoi - but now being considered for Ireland
- implementation TBD (desired feature targeted for Ireland or Jakarata)

## Context

In EdgeX today, sensor/device data collected can be "filtered" by [application services](../../../microservices/application/ApplicationServices.md) before being exported or sent to some [north side](../../../general/Definitions.md#south-and-north-side) application or system. Built-in application service functions (available through the app services SDK) allow EdgeX event/reading objects to be filtered by device name or by device ResourceName.  That is, event/readings can be filtered by:

- which device sent the event/reading (as determined by the Event device property).
- the classification or origin (such as temperature or humidity) of data produced by the device as determined by the Reading's name property (which used to be the value descriptor and now refers to the device ResourceName).

### Two Levels of Device Service Filtering

There are potentially two places where "filtering" in a device service could be useful.  

- One (Sensor Data Filter) - after the device service has communicated with the sensor or device to get sensor values (but before the service creates `Event/Reading` objects and pushes those to core data).  A sensor data filter would allow the device service to essentially ignore some of the raw sensed data.  This would allow for some device service optimization in that the device service would not have perform type transformations and creation of event/reading objects if the data can be eliminated at this early stage.  This first level filtering would, **if put in place**, likely occur in code associated with the read command gets done by the `ProtocolDriver`.
- Two (Reading Filter) - after the sensor data has been collected and read and put into `Event/Reading` objects, there is a desire to filter some of the `Readings` based on the `Reading` values or `Reading` name (which is the device ResourceName) or some combination of value and name.

At this time, **this design only addresses the need for the second filter (Reading Filter)**.  At the time of this writing, no applicable use case has yet to be defined to warrant the Sensor Data Filter.

### Reading Filters
Reading filters will allow, not unlike application service filter functions today, to have `Readings` in an `Event` to be removed if:

- the value was outside or inside some range, or the value was greater than, less than or equal to some value
    - based on the `Reading` value (numeric) of a `Reading` outside a specified range (min/max) described in the service configuration.  Thus avoiding sending in outlier or jittery data `Readings` that could negatively effect analytics.
    - Future scope:  based on the `Reading` value (numeric) equal to or near (with in some specified range) the last reading.  This allows a device service to reduce sending in `Event/Readings` that do not represent any significant change.  This differs from the already implemented onChangeOnly in that it is filtering `Readings` within a specified degree of change.  **Note:** this feature would require caching of readings which has not fully been implemented in the SDK.  The existing mechanism for `autoevents` provides a partial cache.  Added for future reference, but this feature would not be accomplished in the initial implementation; requiring extra design work on caching to be implemented.
    
- the value was the same as some or not the same as some specified value or values (for strings, boolean and other non-numeric values)
- the value matches a pattern (glob and/or regex) when the value is a string.
- the name (the device ResourceName) matched a particular value; in other words match `temperature` or `humidity` as example device resources.

Unlike application services, there is not a need to filter on a device name (or identifier).  Simply disable the device in the device service if all `Event/Readings` are to be stopped for the device.

In the case that all `Readings` of an `Event` are filtered, it is assumed the entire `Event` is deemed to be worthless and not sent to core data by the device service.  If only some `Readings` from and `Event` are filtered, the `Event` minus the filtered `Readings` would be sent to core data.

The filter behaves the same whether the collection of `Readings` and `Events` is triggered by a scheduled collection of data from the underlying sensor/device or triggered by a command request (as from the command service).  Therefore, the call for a command request still results in a successful status code and a return of no results (or partial results) if the filter causes all or some of the readings to be removed.

### Design / Architecture

A new function interface shall be defined that, when implemented, performs a Reading Filter operation.  A ReadingFilter function would take a parameter (an `Event` containing readings), check whether the `Readings` of the `Event` match on the filtering configuration (see below) and if they do then remove them from the `Event`.  The ReadingFilter function would return the `Event` object (minus filtered `Readings`) or `nil` if the `Event` held no more `Readings`.  Pseudo code for the generic function is provided below.  The results returned will include a boolean to indicate whether any `Reading` objects were removed from the `Event` (allowing the receiver to know if some were filtered from the original list).

``` go
func (f Filter) ReadingFilter(lc logger.LoggingClient, event *models.Event) (*models.Event, error, boolean) {
    // depending on impl; filtering for values in/out of a range, >, <, =, same, not same, from a particular name (device resource), etc.
    // The boolean will indicate whether any Readings were filtered from the Event.  
    if (len(event.Reading )) > 0)
        if (len filteredReadings > 0)
            return event, true
        else 
            return event, false
    else
        return nil, true
}
```

Based on current needs/use cases, implementations of the function interface could include the following filter functions:

``` go
func (f Filter) FilterByValue (lc logger.LoggingClient, event *models.Event) (*models.Event, error, boolean) {}

func (f Filter) FilterByResourceNamesMatch (lc logger.LoggingClient, event *models.Event) (*models.Event, error, boolean) {}
```

!!! Note
    The app functions SDK comes with `FilterByDeviceName` and `FilterByResourceName` functions today. The FilterByResourceName would behave similarly to FilterByResourceNameMatch.

    The Filter structure houses the configuration parameters for which the filter functions work and filter on.

!!! Note
    The app functions SDK uses a fairly simple Filter structure.

``` go
    type Filter struct {
	    FilterValues []string
	    FilterOut    bool
    }
```

Given the collection of filter operations (in range, out of range, equal or not equal), the following structure is proposed:

``` go
    type Filter struct {
	    FilterValues []string
        TargetResourceName string
        FilterOp string  // enum of in (in range inclusive), out (outside a range exclusive), eq (equal) or ne (not equal)
    }
```

Examples use of the Filter structure to specify filtering:

``` go
    Filter {FilterValues: {10, 20}, "Int64", FilterOp: "in"} // filter for those Int64 readings with values between 10-20 inclusive
    Filter {FilterValues: {10, 20}, "Int64", FilterOp: "out"} // filter for those Int64 readings with values outside of 10-20.
    Filter {FilterValues: {8, 10, 12}, "Int64", FilterOp: "eq"} //filter for those Int64 readings with values of 8, 10, or 12.
    Filter {FilterValues: {8, 10}, "Int64", FilterOp: "ne"}  //filter for those Int64 readings with values not equal to 8 or 10
    Filter {FilterValues: {"Int32", "Int64"}, nil, FilterOp: "eq"} //filter to be used with FilterByResourceNameMatch.  Filter for resource names of Int32 or Int64.
    Filter {FilterValues: {"Int32"}, nil, FilterOp: "ne"} //filter to be used with FilterByResourceNameMatch.  Filter for resource names not equal to (excluding) Int32.
```

A NewFilter function creates, initializes and returns a new instance of the filter based on the configuration provided.

``` go
func NewReadingNameFilter(filterValues []string, filterOp string) Filter {
    return Filter{FilterValues: filterValues, TargetResourceName string, FilterOp: filterOp}
}
```

### Sharing filter functions

If one were to explore the filtering functions in the app functions SDK [filter.go](https://github.com/edgexfoundry/app-functions-sdk-go/blob/master/pkg/transforms/filter.go) (both `FilterByDeviceName` and `FilterByValueDescriptor`), the filters operate on the `Event` model object and return the same objects (`Event` or nil).  Ideally, since both app services and device services generally share the same interface model (from `go-mod-core-contracts`), it would be the desire to share the same filter functions functions between SDKs and associated services.

Decisions on how to do this in Go - whether by shared module for example - is left as a future release design and implementation task - and as the need for common filter functions across device services and application services are identified in use cases.  C needs are likely to be handled in the SDK directly.

#### Additional Design Considerations

As Device Services do not have the concept of a functions pipeline like application services do, consideration must be given as to how and where to:

- provide configuration to specify which filter functions to invoke
- create the filter
- invoke the filtering functions

At this time, custom filters will not be supported as the custom filters would not be known by the SDK and therefore could not be specified in configuration.  This is consistent with the app functions SDK and filtering.

#### Function Inflection Point

It is precisely after the convert to `Event/Reading` objects (after the async readings are assembled into events) and before returning that result in `common.SendEvent` (in utils.go) function that the device service should invoke the required filter functions.  In the existing V1 implementation of the device-sdk-go, commands, async readings, and auto-events all call the function `common.SendEvent()`.  *Note: V2 implementation will require some re-evaluation of this inflection point.*  Where possible, the implementation should locate a single point of inflection if possible.  In the C SDK, it is likely that the filters will be called before conversion to Event/Reading objects - they will operate on commandresult objects (equivalent to CommandValues).

The order in which functions are called is important when more than one filter is provided.  The order that functions are called should be reflected in the order listed in the configuration of the filters.

Events containing binary values (event.HasBinaryValue), will not be filtered.  Future releases may include binary value filters.

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
    # filter readings where resource name equals Int32 
    ExecutionOrder = "FilterByResourceNamesMatch, FilterByValue"
    [Writable.Filter.Functions.FilterByResourceNamesMatch]
        [Writable.Filter.Functions.FilterByResourceNamesMatch.Parameters]
            FilterValues = "Int32"
            FilterOps ="eq"
    # filter readings where the Int64 readings (resource name) is Int64 and the values are between 10 and 20
    [Writable.Filter.Functions.FilterByValue]
        [Writable.Filter.Functions.FilterByValue.Parameters]
            TargetResourceName = "Int64"
            FilterValues = {10,20}
            FilterOp = "in"
```

## Decision

*To be determined*

## Consequences

This design does not take into account potential changes found with the V2 API.

## References

