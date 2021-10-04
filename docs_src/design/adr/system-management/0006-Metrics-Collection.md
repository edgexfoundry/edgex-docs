# EdgeX Metrics Collection

## Status

### Proposed

!!! Note
    This ADR initially incorporated metrics collection and control plane event processing.  The EdgeX architects felt the scope of the design was too large to cover under one ADR.  Control plane event processing will be covered under a separate ADR in the future.  For the purpose of distinction, metrics collection data and control plane events are defined below:

    **Metric (or telemetry) data** is defined as the count or rate of some action, resource, or circumstance in the EdgeX instance or specific service.  Examples of metrics include:

    - the number of EdgeX Events sent from core data to an application service
    - the number of requests on a service API
    - the average time it takes to process a message through an application service
    - The number of errors logged by a service

    **Control plane events** (CPE) are defined as `events` that occur within an EdgeX instance.  Examples of CPE include:

    - a device was provisioned (added to core metadata)
    - a service was stopped
    - service configuration has changed

    Note CPE should not be confused with core data Events.  Core data Events represent a collection (one or more) of sensor/device readings.  Core data Events represent sensing of some measured state of the physical world (temperature, vibration, etc.).  CPE represents the detection of some happening inside of the EdgeX software.

!!! Info
    Information in *italics* indicates topics for discussion without suggested proposal at this time.

## Context

[System Management services](../../../microservices/system-management/Ch_SystemManagement.md) (SMA and executors) currently provide a limited set of “metrics” to requesting clients (3rd party applications and systems external to EdgeX).  Namely, it provides requesting clients with service CPU and memory usage; both metrics about the resource utilization of the service itself versus metrics that are about what is happening inside of the service.  Arguably, the current system management metrics can be provided by the container engine and orchestration tools (example: by Docker engine) or by the underlying OS tooling.

!!! Info
    The SMA has been deprecated and will be removed in a future, yet named, release.

Going forward, users of EdgeX will want to have more insights – that is more metrics telemetry – on what is happening directly in the services and the tasks that they are preforming.  In other words, users of EdgeX will want more telemetry on service activities to include:
- sensor data collection (how much, how fast, etc.)
- command requests handled (how many, to which devices, etc.)
- sensor data transformation as it is done in application services (how fast, what is filtered, etc)
- sensor data export (how much is sent, how many exports have failed, etc. )
- API requests (how often, how quickly, how many success versus failed attempts, etc.)
- bootstrapping time (time to come up and be available to other services)
- activity processing time (amount of time it takes to perform a particular service function - such as respond to a command request)

### Definitions

**Metric (or telemetry) data** is defined as the count or rate of some action, resource, or circumstance in the EdgeX instance or specific service.  Examples of metrics include:

- the number of EdgeX Events sent from core data to an application service via message bus (or via device service to application service in Ireland and beyond)
- the number of requests on a service API
- the average time it takes to process a message through an application service
- The number of errors logged by a service

The collection and dissemination of metric data will require internal service level instrumentation (relevant to that service) to capture and send data about relevant EdgeX operations.  EdgeX does not currently offer any service instrumentation.

### Metric Use

As a first step in implementation of metrics data, EdgeX will make metric data available to other subscribing 3rd party applications and systems, but will not necessarily consume or use this information itself.  

In the future, EdgeX may consume its own metric data.  For example, EdgeX may, in the future, use a metric on the number of EdgeX events being sent to core data as the means to throttle back device data collection.

In the future, EdgeX application services may optionally subscribe to a service's metrics messages bus (by attaching to the appropriate message pipe for that service).  Thus allowing additional filtering, transformation, endpoint control of metric data from that service.  At the point where this feature is supported, consideration would need to be made as to whether all events (sensor reading messages and metric messages) go through the same application services.

At this time, EdgeX will not persist the metric data (except as it may be retained as part of and message bus subsystem such as in an MQTT broker).  Consumers of metric data are responsible for persisting the data if needed, but this is external to EdgeX.  Persistence of metric information may be considered in the future based on requirements and adopter demand for such a feature.

In general, EdgeX metrics are meant to provide external applications and systems better information about what is happening "inside" EdgeX services and the associated devices with which it communicates.

### Requirements

- Services will push specified metrics collected for that service to a specified (by configuration) message endpoint (as supported by the EdgeX  message bus implementation; currently either Redis Pub/Sub or MQTT implementations are supported)
    - Each service will have configuration that specifies a message endpoint for the service metrics.  The metrics message topic communications may be secured or unsecured (just as application services provide the means to export to secured or unsecured message pipes today).
- All services must document what metrics they offer.
- All EdgeX services must implement a common metrics interface/contract that defines an API set about service metrics.
    - The metrics REST endpoints implemented on each service are not there to provide the metrics data, but to know what metrics the service provides, to know the the current state for each metric (`on` or `off`), and to provide a means to turn `on` or `off` the metrics collection.  The actual metric data will be provided, when collected, in messages to a message bus.
    - The interface would include the definition of a GET REST endpoint that responds with the metrics that the service offers (and whether that metric is currently `on` or `off`). The proposed endpoint format:  **/api/v2/metrics**.
    - The interface would define PUT and PATCH REST endpoints that allows the user to toggle between `on` and `off` for any metric.  The proposed endpoint format:  **/api/v2/metrics**.  In this REST request body would be the list of metric names to be turned `on` (or those turned `on` or `off` in the case of PATCH).  It is assumed that those metrics not listed are to be turned `off` in the PUT call where PATCH request is explicit about which metrics are turned `on` or `off` and leaves others unchanged.
- Services will have configuration which allows EdgeX system managers to select which metrics are `on` or `off` by default - in other words providing the initial bootstrapping configuration that determines what metrics are collected and reported by default.
    - When a metric is turned `off` the service does not report the metric.  When a metric is turned `on` the service collects and sends the metric to the designated message topic.
    - Per REST API described above, the `on` and `off` control of the metrics collected can be changed during runtime of the service.
    - Metrics collection must be pushed to the designated message topic on some appointed schedule.  The schedule would be designated by configuration in the schedule service or done in a way similar to auto events in device services.  
        - *Do we want to dictate this or allow services to implement as they see fit?*
            - Recommendation by @cloudxxx8 - have internal scheduler but provide option to use external scheduler.   The service then has to provide the API for the external to call for collection.  Suggest using a design similar to auto discovery in device services.
        - *Also, should there be an interval per metric or a single interval for all metrics collected and pushed?*
            - Recommendation by @cloudxxx8 to support interval per metric but to have one for all as default

!!! Info
    Initially, it was proposed that metrics be associated with a "level" and allow metrics to be turned on or off by level (like levels associated to log messages in logging).  The level of metrics data seems arbitrary at this time and considered too complex for initial implementation.  This may be reconsidered in a future release and based on new requirements/use cases.

    It was also proposed to categorize or label metrics - essentially allowing grouping of various metrics.  This would allow groups of metrics to be turned on or off, and allow metrics to be organized per the group when reporting.  At this time, this feature is also considered beyond the scope of the initial implementation and to be reconsidered in a future release based on requirements/use case needs.

### Requested Metrics

The following is a list of example metrics requested by the EdgeX community and adopters for various service areas.  Again, metrics would generally be collected and pushed to the message topic in some configured interval (example: 1/5/15 minutes or other defined interval).  The exact metrics collected by each service will be determined by the service implementers (or SDK implementers in the case of the app functions and device service SDKs).

#### General

The following metrics apply to all (or most) services.

- Service uptime (time since last service boot)
- Cumulative number of API requests succeeded / failed / invalid (2xx vs 5xx vs 4xx)
- Avg response time (in milliseconds or appropriate unit of measure) on APIs
- Avg and Max request size

#### Core/Supporting

- Latency (measure of time) an event takes to get through core data
- Latency (measure of time) a command request takes to get to a device service
- Indication of health – that events are being processed during a configurable period
- Number of events in persistence
- Number of readings in persistence
- Number of validation failures (validation of device identification)
- Number of notification transactions
- Number of notifications handled
- Number of failed notification transmissions
- Number of notifications in retry status

#### Application Services

- Processing time for a pipeline; latency (measure of time) an event takes to get through an  application service pipeline
- DB access times
- How often are we failing export to be sent to db to be retried at a later time
- What is the current store and forward queue size
- How much data (size in KBs or MBs) of packaged sensor data is being sent to an endpoint (or volume)
- Number of invalid messages that triggered pipeline
- Number of events processed

#### Device Services

- Number of devices managed by this DS
- Device Requests (which may be more informative than reading counts and rates)

#### Security

Security metrics may be more difficult to ascertain as they are cross service metrics.  They may have to be dealt with per service.  Also, true threat detection based on metrics may be a feature best provided by 3rd party based on particular threats and security profile needs.

- Number of API requests denied due to wrong access token (Kong) per service and within a given time
- Number of secrets accessed per service name
- Count of any accesses and failures to the data persistence layer
- Count of service start and restart attempts

### Design Proposal

- Each metric must have a unique name (or key) associate with it.  Because some metrics are reported from multiple services (such as service uptime), the name is not required to be unique across all services.  However, the metric name and the service name/key for a metric (see Bucket definition below) along with the origin timestamp would uniquely identify a metric from a service at a designated time.
- All services will use/integrate go-mod-messaging (if not already integrated).
- A new metric DTO (Telemetry/Bucket) is required for services to structure the metric data.  The model/DTO will have similarities to the core event/reading model/DTO.
    - The DTO for the metric data will allow originating service information (the service key) to be provided in the DTO
    - The proposed message structure (DTO) for metrics (for inclusion in go-mod-core-contracts) is:
 
``` go
type Telemetry struct {
    Id          string            `json:"id,omitempty" codec:"id,omitempty"`  // UUID to identify the telemetry group
    Service     string            `json:"device,omitempty" codec:"device,omitempty"`  // originating service key
    Origin      int64             `json:"origin,omitempty" codec:"origin,omitempty"`
    Buckets    []Bucket           `json:"readings,omitempty" codec:"buckets,omitempty"`
    Tags        map[string]string `json:"tags,omitempty" codec:"tags,omitempty" xml:"-"`
}

type Bucket struct {
    Id            string `json:"id,omitempty" codec:"id,omitempty"`  // UUID to identify the Bucket
    Origin        int64  `json:"origin,omitempty" codec:"origin,omitempty"`
    Service       string `json:"device,omitempty" codec:"device,omitempty"`   // originating service key
    Name          string `json:"name,omitempty" codec:"name,omitempty"`  // metric name key
    Value         string `json:"value,omitempty" codec:"value,omitempty"` // metric value
    ValueType     string `json:"valueType,omitempty" codec:"valueType,omitempty"`  // metric value type
}
```

!!! Note
    Metrics are considered immutable and therefore not requiring a modified timestamp.

    *For consideration, should we keep the metric data values simple (i.e. just a number field) since the metrics are just numbers and thereby avoid having to deal with types (pulling ValueType from above).  Even times could be sent as UTC number values.*

    *Also for consideration, can we simplify the structures?*

    - would the telemetry and bucket need an ID?  
    - would origin timestamp need to be put on the telemetry object since it is on a Bucket?
    - would originating service need to be put in both telemetry and bucket objects?
    - Can the description be found in documentation and therefore left off of the Bucket?  *(@cloudxxx8 recommends removing.  Can add back in if there are dissenting opinions)*

#### REST endpoints

!!! Note
    Again, these REST endpoints are per service and meant to control which metrics for a service are turned on or off.  The REST endpoints do not provide metrics data.

- Proposed endpoint for the REST endpoint that responds with what metrics the service offers is:  /api/v2/metrics
- Body of the GET response would contain a JSON list of metrics (by metric name key) that are `on`
- Body of the PUT request would contain a JSON list of the metrics that are to be turned `on` (others are assumed to be turned `off`)
- Body of the PATCH request would contain a JSON list of the metrics that are to be turned `on` or `off` - leaving all other metrics unchanged

#### Configuration
- Configuration, not unlike that provided in core data or any device service, will specify what message bus locations where the metrics messages should be sent.
- In fact, the message bus configuration will use (or reuse if the service is already using the message bus) the common message bus configuration as defined below.
- Metrics will be published to an /edgex/metrics/[service-name] topic where the service name will be added per service
- Common configuration for each service for message queue configuration - inclusive of metrics:

``` yaml
[MessageQueue]
Protocol = 'redis'  ## or 'tcp'
Host = 'localhost'
Port = 5573
Type = 'redis'  ## or 'mqtt'
PublishTopicPrefix  = 'edgex/metrics' # /<service-name> will be added to this Publish Topic prefix
  [MessageQueue.Optional]
  # Default MQTT Specific options that need to be here to enable environment variable overrides of them
  # Client Identifiers
  ClientId = "device-virtual"
  # Connection information
  Qos = "0" # Quality of Sevice values are 0 (At most once), 1 (At least once) or 2 (Exactly once)
  KeepAlive = "10" # Seconds (must be 2 or greater)
  Retained = "false"
  AutoReconnect = "true"
  ConnectTimeout = "5" # Seconds
  SkipCertVerify = "false" # Only used if Cert/Key file or Cert/Key PEMblock are specified
```

#### Library Support

go-mod-contracts would need to add the proposed DTO and request/response objects.
go-mod-messaging should support the ability to put messages of any DTO and so therefore would require little or no change to support this ADR.
As each service would determine when and what metrics to collect and push to the message bus, this can be implemented by each service as needed.
There may be a desire to add common functionality in support of the REST handlers for getting the list of supported metrics and for enabling/disabling the metrics collection.  This can be explored at implementation time.

Use of [go-metrics](https://github.com/rcrowley/go-metrics) (a GoLang library to publish application metrics) would allow EdgeX to utilize (versus construct) a library utilized by over 7 thousand projects.  It provides the means to capture various types of metrics in a registry (a sophisticated map).  The metrics can then be published (`reported`) to a number of well known systems such as InfluxDB, Graphite, DataDog, and Syslog.  go-metrics is a Go library made from original Java package https://github.com/dropwizard/metrics.

** Considerations in the use of go-metrics **
- This is a Golang only library.  Using this library would not provide with any package to use for the C services.  If there are expectations for parity between the services, this may be more difficult to achieve given the features of go-metrics.
- go-metrics will still require the EdgeX team to develop a bootstrapping apparatus to take the metrics configuration and register each of the metrics defined in the configuration in go-metrics.
- go-metrics would also require the EdgeX team to develop the means to periodically extract the metrics data from the registry and ship it via message bus (something the current go-metrics library does not do).
- While go-metrics offers the ability for data to be reported to other subsystems, it would required EdgeX to expose these capabilities (possibly through APIs) if a user wanted to export to these subsystems in addition to the message bus.

** Community questions about go-metrics **
Per the Monthly Architect's meeting of 9/20/21):

- How it manages the telemetry data (persistence, in memory, database, etc.)?
    - In memory - in a "registry"; essentially a key/value store where the key is the metric name
- Does it offer a query API (in order to easily support the ADR suggested REST API)?
    - Yes - metrics are stored in a "Registry" (MetricRegistry - essentially a map).  Get (or GetAll) methods provided to query for metrics
- What does the go-metrics package do so that its features can become requirements for C side?
    - About a dozen types of metrics collection (simple guage or counter to more sophisticated structures like Histograms) - all stored in a registry (map).
- How is the data made available?
    - Report out (export or publish) to various integrated packages (InfluxDB, Graphite, DataDog, Syslog, etc.).  Nothing to MQTT or other base message service.  This would have to be implemented from scratch.
- Can the metric/telemetry count be reset if needed? Does this happen whenever it posts to the message bus?  How would this work for REST?
    - Yes, you can unregister and re-register the metric.  A REST API would have to be constructed to call this capability.

As an alternative to go-metrics, there is another library called [OpenCensus](https://opencensus.io/).  This is a multi-language metrics library, including Go and C++.  This library is more feature rich.  OpenCensus is also roughly 5x the size of the go-metrics library.

#### Additional Open Questions

- *Should consideration be given to allow metrics to be placed in different topics per name?  If so, we will have to add to the topic name like we do for device name in device services?*
- *Should consideration be given to incorporate alternate protocols/standards for metric collection such as https://opentelemetry.io/ or https://github.com/statsd/?*
- *Should we provide a standard interface for the function that gets called by a schedule service (internal or external) to fetch and publish the desired metrics at the appointed time?*
    - *Do we dictate the use of the scheduler service for this or use the internal scheduler approach?*

## Decision

*To be determined*

## Consequences

- Should there be a *global* configuration option to turn all metrics off/on?
    - * EdgeX doesn't yet have global config so this will have to be by service. *
- Given the potential that each service publishes metrics to the same message topic, 0MQ is not implementation option unless each service uses a different 0MQ pipe (0MQ topics do not allow multiple publishers).  
    - *Like the DS to App Services implementation, do we allow 0MQ to be used, but only if each service sends to a different 0MQ topic?  Probably not.*
- We need to avoid service bloat.  EdgeX is not an enterprise system.  How can we implement in a concise and economical way?
- SMA reports on service CPU, memory, configuration and provides the means to start/stop/restart the services.  This is currently outside the scope of the new metric collection/monitoring.
    - In the future, 3rd party mechanisms which offer the same capability as SMA may warrant all of SMA irrelevant.
- The existing notifications service serves to send a notification via alternate protocol outside of EdgeX.  This communication service is provided as a generic communication instrument from any micro service and is independent of any type of data or concern.
    - In the future, the notification service could be configured to be a subscriber of the metric messages and trigger appropriate external notification (via email, SMTP, etc.).

## Reference
Possible standards for implementation

- [Open Telemetry](https://opentelemetry.io/)
- [statsd](https://github.com/statsd/)
- [go-metrics](https://github.com/rcrowley/go-metrics)
- [OpenCensus](https://opencensus.io/)