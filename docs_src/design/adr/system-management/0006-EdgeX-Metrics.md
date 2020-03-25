
# EdgeX Metrics Collection  

## Status 

**proposed** - for Hanoi release

## Requirements
System Management services currently provide a limited set of “metrics” to requesting clients.  Namely, it provides requesting clients with service CPU and memory usage; both metrics about the resource utilization of the service itself versus metrics that are about what is happening inside of the service.  Arguably, the current system management metrics can be provided by the container engine and orchestration tools (example: by Docker engine) or by the underlying OS tooling.

Going forward, users of EdgeX will want to have more insights – that is more metrics – on what is happening in the data collection, device management and monitoring, and event handling processes inside of Edge services.  The collection of this type of metric may require service level instrumentation relevant to capture and send data (what has been termed control plane data) about relevant EdgeX operations.  EdgeX does not currently offer any service instrumentation. 

### Requested Metrics
**General**
- Latency statistics – from device sensor down south, going up north, and traversing back (and vice - versa)
- Throughput of events
- Indication of health – that events are being processed
- Validation failures
- Data/events not transiting the system; being blocked somewhere and queueing up
- The volume of data each edge system is producing north bound (total KBs of event data collected and sent within a defined time period, number of metrics, log data, etc. collected over a period of time and sent to another system)

**Core/Supporting**
- Number of API requests/sec
- Avg response time (in milliseconds or appropriate unit of messure)
- Service uptime
- Request success vs. failure vs. invalid (2xx vs 5xx vs 4xx)
- Avg request size
- Max request size
- Auth/auth failures (once we get there)

**Application Services**
- Processing time for a pipeline
- DB access times
- How often are we failing export to be sent to db to be retried at a later time
- What is the current store and forward queue Size
- How much data (size in KBs or MBs) of packaged sensor data is being sent to an endpoint (or volume)
- Track important expected/Common Error Counts and Stats
- Number of invalid messages that triggered pipeline
- Number of events processed

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
- Number of devices managed by this DS
- Device Requests (which may be more informative that reading counts and rates)
- Cumulative number succeeded / failed
  - Number processed in last 1 / 5 / 15 minutes (or other defined intervals)
  - Average time to process: all-time / last 5

**Miscellaneous requirements**

- It would be nice to be able to set granularity of telemetry based on INFO, DEBUG, VERBOSE; something like a telemetryLevel option in config
- Current system management agent metric endpoint doesn’t return metrics in a timely fashion; i.e. takes more than a second to return. Talking directly to an individual service for metrics is quicker.
- Metrics that system management agent provides shouldn’t include those that aren’t EdgeX-specific (i.e. memory and cpu usage) and which can’t be gathered using other tools/technologies. events. Based on prior experience, don’t instrument all the things. Define your metrics first and provide an initial limited view. 
- Need to avoid service bloat.  EdgeX is not an enterprise system.  How can we implement in a concise and economical way.

## Context 

### Early Design Ideas ###
Per System Management WG Meeting of March 20, the following ideas were surfaced:
Address service specfic metrics with two underlying subsystems:

1 - code added to each service (perhaps by way of DI injected object defined in a module) that collects specific service metrics and pushes these metric data out in a common way.  This would be similar to how all device services push Event/reading objects to core data, but in this case, the "where it gets pushed to" is more flexible.

2 - set up a central service (or reuse something like SMA) to be the processing center for the incoming metrics data objects.  This could even be built later and just allow services to push their metrics objects to some configured message bus to start.  Or the metrics collection could be pushed as another type of Event to core data and onto application services for processing.

The idea is that 1 and 2 above should be independent of one another.  #2 above may include use of existing services, creation of a new service, or doing nothing at first and just having services configured to send metrics data to some message endpoint.

#### Service Level Metrics Collection ####
As for part #1, it was suggested that all services should be expected to use / integrate with go-mod-messaging to facilitate sending the metrics object messages to some "bus".

It was also suggested that each service have a couple of new REST endpoints that allow the service to:

a) provide a list of the metrics the can report

b) provide a means to turn on and off which metrics get sent

Each service would need additional configuration to point the metrics data objects to be sent, via go-mod-messaging, to a configuration specified endpoint(s).

Design work is needed to define the DTO objects of metrics communication.

#### Metrics Consumer or Collection Service ####
As for part #2 above, there are many options:
* The SMA could serve to collect the metric data and then transmit that for all services to an endpoint (push model)
* The SMA could serve to collect the metric data and the offer query REST endpoints to get the metric data (pull model which was least favored by the architects)
* Have services send their metrics objects in Event/Reading form through Core Data where (special) application services could filter out and deal with metrics data.  Under this design then:
  * Metadata descriptions along with typing/tagging value descriptors (or their equivalent) would define control plane data from each service.  In terms of data, control plane data would look no different than sensor data.  The difference is that the data could come from every service (versus device services).
  * Special tags or marks in the current Event/reading model may be required to designated metric data versus standard sensor data.  The beauty of this design is that it requires no or minimal changes to services to implement (although each service must add code to collect control plane metrics and send them to core data.
  * Application services would filter, transform, and otherwise export control plane data (as it does sensor data today) in the same fashion as it gets sensor data to 3rd parties.  It would allow rules engine to fire on the part of control plane data – example command a device or eventually send an alert/notification.  A special application service could be used to deal with particulars of control plane export if necessary.
  * The existing system management service could would not have to change.  It would still provide for start/top/restart operations, service level metrics (CPU, memory), and provide get/set configuration operations.  If required, the SMA could also provide control plane data queries for a request/response style interface for control plane data, while the application services provide a push of control plane data to HTTP or even message bus endpoints.
* A new service could be created to serve as the collection point, and allow that service (and lots of alternate implementations of that service) to do what it wishes with the metrics data on arrival (persist it, store and forward, forward it via message bus, etc.).  We could offer some reference implementations or simply have an implementation that logs the metrics data just to be a placeholder and implementation of any API on the service.
* Do nothing special - simply allow each service to send its metrics data to a specified message endpoint configured in the service.  This could even be different message endpoints for each service.  This would provide ultimate flexibility but also put the onus on the end user to architect a solution on collection and movement of metric data.

#### Integration of 3rd party tools ####
While EdgeX could provide integration to something like Prometheus, it is viewed that this exercise is best accomplished by end users or commercialization efforts.  Metrics collection should help facilitate use of tool like Prometheus and make it easier to integrate (perhaps even offering example code in holding), but EdgeX should avoid any tight integration to specific tools.

## Decision 

None – to be discussed in Hanoi pre-wire, Hanoi F2F planning
 
## Consequences 
Impacts to metadata (profile/service) models.  How would control plane data be specified?

Would there be any common metrics required of all services and necessitate a module to implement?  Would there have to be some metrics template code (SDK) be created to provide all services with metrics collection and sending boiler plates?

Impacts to SMA.  Would an control plane data query be required and would that come from core data or from SMA (accessing core data persistence)?

