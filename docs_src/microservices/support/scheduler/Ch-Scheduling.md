# Scheduling

![image](EdgeX_SupportingServicesScheduling.png)

## Introduction

The Support-scheduler service executes operations on a configured interval or schedule. Two default scheduled operations are:

1 - Clean up Core-data events/readings that have been moved ("pushed") to external applications/systems like a cloud provider. This is the "Scrubbed Pushed" operation. Scheduler parameters around this operation determine how often and where to call into core data to invoke this clean up of unneeded data operation.

2 - Clean up of Core-data events/readings that have been persisted for an extended period. In order to prevent the edge node from running out of space, these old events/readings are removed. This is the "ScrubAged" operation. Scheduler parameters around this operation determine how often and where to call into Core-data to invoke this operation to expunge of old data.

The removal of both exported records and stale records occurs on a
configurable schedule. By default, both of the default actions above are invoked once a day at midnight.

Support-scheduler uses a data store to persist the Interval(s) and
IntervalAction(s). Persistence is accomplished the Scheduler DB located
in your current configured database for EdgeX.

## Data Dictionary

  |Class Name  | Description|
  |----------------| ---------------------------------------------------------|
  |Interval        | An object defining a specific "period" in time.|
  |IntervalAction  | The action taken by a Service when the Interval occurs.|
  
## Configuration Properties

The following are extra configuration parameters specific to the Support-Scheduler service. Please refer to the general Configuration [documentation](https://docs.edgexfoundry.org/1.2/microservices/configuration/Ch-Configuration/#configuration) for configuration properties common across all services.

|Configuration  |     Default Value     |             Dependencies|
| --- | --- | -- |
| **Intervals govern the timing of operations in the support-scheduler service. By default, only one interval is created to run a job at midnight. However you could follow the example to add as many as desired.** |
| Intervals Midnight Name | midnight | The name of the given interval. |
| Intervals Midnight Start | 20180101T000000 | The start time of the given interval in ISO 8601 format. |
| Intervals Midnight Frequency | 24h | Periodicity of the interval. |
| **IntervalActions govern the actions taken by the scheduler when a tick triggers an interval.** |
| IntervalActions ScrubPushed Name | scrub-pushed-events | The name of the given action. |
| IntervalActions ScrubPushed Host | localhost | The host targeted by the action when it activates. |
| IntervalActions ScrubPushed Port | 48080 | The port on the targeted host |
| IntervalActions ScrubPushed Protocol | http | The protocol used when interacting with the targeted host. |
| IntervalActions ScrubPushed Method | DELETE | Assuming a RESTful operation, the HTTP method to be invoked by the action. |
| IntervalActions ScrubPushed Target | core-data | The name of the targeted application |
| IntervalActions ScrubPushed Path | /api/v1/event/scrub | In the case of a RESTful operation, the path to be invoked in combination with the Method. |
| IntervalActions ScrubPushed Interval | midnight | The interval to which the action is associated. When the interval is activated, all associated actions will be invoked.|
| IntervalActions ScrubAged Name | scrub-aged-events | The name of the given action. |
| IntervalActions ScrubAged Host | localhost | The host targeted by the action when it activates. |
| IntervalActions ScrubAged Port | 48080 | The port on the targeted host |
| IntervalActions ScrubAged Protocol | http | The protocol used when interacting with the targeted host. |
| IntervalActions ScrubAged Method | DELETE | Assuming a RESTful operation, the HTTP method to be invoked by the action. |
| IntervalActions ScrubAged Target | core-data | The name of the targeted application |
| IntervalActions ScrubAged Path | /api/v1/event/removeold/age/604800000 | In the case of a RESTful operation, the path to be invoked in combination with the Method. |
| IntervalActions ScrubAged Interval | midnight | The interval to which the action is associated. When the interval is activated, all associated actions will be invoked.|
| | | |