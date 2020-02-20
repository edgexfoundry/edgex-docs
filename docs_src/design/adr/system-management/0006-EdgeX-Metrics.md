# EdgeX Metrics Collection  

## Status 

under review and consideration - for Hanoi release

## Requirements
System Management services currently provide a limited set of “metrics” to requesting clients.  Namely, it provides requesting clients with service CPU and memory usage; both metrics about the resource utilization of the service itself versus metrics that are about what is happening inside of the service.  Arguably, the current system management metrics can be provided by the container engine and orchestration tools (example: by Docker engine) or by the underlying OS tooling.

Going forward, users of EdgeX will want to have more insights – that is more metrics – on what is happening in the data collection, device management and monitoring, and event handling processes inside of Edge services.  The collection of this type of metric may require service level instrumentation relevant to capture and send data (what has been termed control plane data) about relevant EdgeX operations.  EdgeX does not currently offer any service instrumentation. 

### Requested Metrics
**General**
-	Latency statistics – from device sensor up north and back(and vice - versa).
-	Throughput of events
-	Indication of health – that events are being processed
-	Validation failures
-	Data/events not transiting the system; being blocked somewhere and queueing up
-	The volume of data each edge system is producing north bound.

**Core/Supporting**
-	Number of API requests/sec
-	Avg response time
-	Service uptime
-	Request success vs. failure vs. invalid (2xx vs 5xx vs 4xx)
-	Avg request size
-	Max request size
-	Auth/auth failures (once we get there)

**Application Services**
-	Processing time for a pipeline
-	DB access times
-	How often are we failing export to be sent to db to be retried at a later time
-	What is the current queue Size
-	How much data is being sent to an endpoint(Volume)
-	Track important expected/Common Error Counts and Stats
-	Number of invalid Events seen
-	Number of events processed

**Security**

Security metrics may be more difficult to ascertain as they are cross service metrics (perhaps put in the general category).  Also, true threat detection based on metrics may be a feature best provided by 3rd party based on particular threats and security profile needs.
- Number of logins and login failures per service and within a given time
- Number of secrets accessed per service name 
- Count of any accesses and failures to the data persistence layer
- Count of start and restart attempts 
- Registration of new devices and services (allowing for future quarantine mechanism) 
- Indication of any new uploading of new CA/import to vault
- 
**Device Services**
-	Number of devices managed by this DS
-	Device Requests (which may be more informative that reading counts and rates)
- Cumulative number succeeded / failed
  -	Number processed in last 1 / 5 / 15 minutes (or other defined intervals)
  -	Average time to process: all-time / last 5

**Miscellaneous requirements**

-	It would be nice to be able to set granularity of telemetry based on INFO, DEBUG, VERBOSE; something like a telemetryLevel option in config
-	Current system management agent metric endpoint doesn’t return metrics in a timely fashion; i.e. takes more than a second to return. Talking directly to an individual service for metrics is quicker.
-	Metrics that system management agent provides shouldn’t include those that aren’t EdgeX-specific (i.e. memory and cpu usage) and which can’t be gathered using other tools/technologies. events. Based on prior experience, don’t instrument all the things. Define your metrics first and provide an initial limited view. 
-	Need to avoid service bloat.  EdgeX is not an enterprise system.  How can we implement in a concise and economical way.


## Context 
It is recommended that each service be responsible for its own metric data collection and deposit into the central data repository – core data.  Core data is already uniquely qualified to receive service data “readings”, persist them and make them available to application services for other apps, enterprise, cloud system use or internal decision making (rules engine).

Metadata descriptions along with typing/tagging value descriptors (or their equivalent) would define control plane data from each service.  In terms of data, control plane data would look no different than sensor data.  The difference is that the data could come from every service (versus device services).

Special tags or marks in the current Event/reading model may be required to designated metric data versus standard sensor data.  The beauty of this design is that it requires no or minimal changes to services to implement (although each service must add code to collect control plane metrics and send them to core data).

There may be a need to isolate control plane from data plane data in core data.   This could be achieved in several ways:
-	Use a separate document store for control plane readings/events (vs sensor data today)
-	Queries would have to include a parameter suggesting responses should only consider only data plane data, only control plane data or both

But why would control plane data be treated any different that sensor data?  In fact, in some use cases, control plane data would be important “sensed” data – such as the whether sensor is reporting or not.

Application services would filter, transform, and otherwise export control plane data (as it does sensor data today) in the same fashion as it gets sensor data to 3rd parties.  It would allow rules engine to fire on the part of control plane data – example command a device or eventually send an alert/notification.  A special application service could be used to deal with particulars of control plane export if necessary.

The existing system management service could would not have to change.  It would still provide for start/top/restart operations, service level metrics (CPU, memory), and provide get/set configuration operations.  If required, the SMA could also provide control plane data queries for a request/response style interface for control plane data, while the application services provide a push of control plane data to HTTP or even message bus endpoints.

## Decision 

None – to be discussed in Hanoi pre-wire, Hanoi F2F planning
 
## Consequences 
Impacts to metadata (profile/service) models.  How would control plane data be specified?

Would there be any common metrics required of all services and necessitate a module to implement?  Would there have to be some metrics template code (SDK) be created to provide all services with metrics collection and sending boiler plates?

Impacts to SMA.  Would an control plane data query be required and would that come from core data or from SMA (accessing core data persistence)?
