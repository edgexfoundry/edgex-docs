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

!!! Note
    There may be additional specific metrics for each device service.  For example, the ONVIF device service may report number of times camera tampering was detected. 

#### Security

Security metrics may be more difficult to ascertain as they are cross service metrics.  They may have to be dealt with per service.  Also, true threat detection based on metrics may be a feature best provided by 3rd party based on particular threats and security profile needs.

- Number of API requests denied due to wrong access token (Kong) per service and within a given time
- Number of secrets accessed per service name
- Count of any accesses and failures to the data persistence layer
- Count of service start and restart attempts

### Design Proposal

#### Collect and Push Architecture

Metric data will be collected and cached by each service.  At designated times (kicked off by configurable schedule), the service will collect telemetry data from the cache and push it to a designated message bus topic.

#### Metrics Messaging

Cached metric data, at the designated time, will be marshaled into a message and pushed to the pre-configured message bus topic.

Each metric message consists of several key/value pairs:
- a **required** name (the name of the metric) such as service-uptime
- a **required** value which is the telemetry value collected such as 120 as the number of hours the service has been up.
- a **required** timestamp is the time (in Epoch timestamp/milliseconds format) at which the data was collected (similar in nature to the origin of sensed data). 
- an optional collection (array) of tags.  The tags are sets of key/value pairs of strings that provide amplifying information about the telemetry.  Tags may include:
    - originating service name
    - unit of measure associated with the telemetry value
    - value type of the value
    - additional values when the metric is more than just one value (example: when using a histogram, it would include min, max, mean and sum values)

The metric name must be unique for that service.  Because some metrics are reported from multiple services (such as service uptime), the name is not required to be unique across all services.

All information (keys, values, tags, etc.) is in string format and placed in a JSON array within the message body.  Here are some example representations:

**Example metric message body with a single value**
{"name":"service-up", "value":"120", "timestamp":"1602168089665570000", "tags":{"service":"coredata","uom":"days","type":"int64"}}

**Example metric message body with multiple values**
{"name":"api-requests", "value":"24", "timestamp":"1602168089665570001", "tags":{"service":"coredata","uom":"count","type":"int64", "mean":"0.0665", "rate1":"0.111", "rate5":"0.150","rate15":"0.111"}}

!!! Note
    The key or metric name must be unique when using go-metrics as it requires the metric name to be unique per the registry.  Metrics are considered immutable.

#### REST endpoints

!!! Note
    Again, these REST endpoints are per service and meant to control which metrics for a service are turned on or off.  The REST endpoints do not provide metrics data.

- Proposed endpoint for the REST endpoint that responds with what metrics the service offers is:  /api/v2/metrics
- Body of the GET response would contain a JSON list of metrics (by metric name key) that are `on`
- Body of the PUT request would contain a JSON list of the metrics that are to be turned `on` (others are assumed to be turned `off`)
- Body of the PATCH request would contain a JSON list of the metrics that are to be turned `on` or `off` - leaving all other metrics unchanged

#### Configuration
- Configuration, not unlike that provided in core data or any device service, configuration will specify the message bus type and locations where the metrics messages should be sent.
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

Additional configuration must be provided (in the service configuration.toml) to trigger the collection of telemetry from the metrics cache and sending it into the appointed message bus.
``` yaml
[[Metrics.Collection]]
Interval = "30s"
```

#### Library Support
Each service will now need go-mod-messaging support.
Each service would determine when and what metrics to collect and push to the message bus, but will use a common library choose for each EdgeX language supported (Go or C currently)

There may be a desire to add common functionality in support of the REST handlers for getting the list of supported metrics and for enabling/disabling the metrics collection.  This can be explored at implementation time.

Use of [go-metrics](https://github.com/rcrowley/go-metrics) (a GoLang library to publish application metrics) would allow EdgeX to utilize (versus construct) a library utilized by over 7 thousand projects.  It provides the means to capture various types of metrics in a registry (a sophisticated map).  The metrics can then be published (`reported`) to a number of well known systems such as InfluxDB, Graphite, DataDog, and Syslog.  go-metrics is a Go library made from original Java package https://github.com/dropwizard/metrics.

A similar package would need to be selected for C.

** Considerations in the use of go-metrics **
- This is a Golang only library.  Using this library would not provide with any package to use for the C services.  If there are expectations for parity between the services, this may be more difficult to achieve given the features of go-metrics.
- go-metrics will still require the EdgeX team to develop a bootstrapping apparatus to take the metrics configuration and register each of the metrics defined in the configuration in go-metrics.
- go-metrics would also require the EdgeX team to develop the means to periodically extract the metrics data from the registry and ship it via message bus (something the current go-metrics library does not do).
- While go-metrics offers the ability for data to be reported to other subsystems, it would required EdgeX to expose these capabilities (possibly through APIs) if a user wanted to export to these subsystems in addition to the message bus.
- Per the Kamakura Planning Meeting, it was noted that go-metrics is already a dependency in our Go code due to its use other 3rd party packages (see https://github.com/edgexfoundry/edgex-go/blob/4264632f3ddafb0cbc2089cffbea8c0719035c96/go.sum#L18).


** Community questions about go-metrics **
Per the Monthly Architect's meeting of 9/20/21):

- How it manages the telemetry data (persistence, in memory, database, etc.)?
    - In memory - in a "registry"; essentially a key/value store where the key is the metric name
- Does it offer a query API (in order to easily support the ADR suggested REST API)?
    - Yes - metrics are stored in a "Registry" (MetricRegistry - essentially a map).  Get (or GetAll) methods provided to query for metrics
- What does the go-metrics package do so that its features can become requirements for C side?
    - About a dozen types of metrics collection (simple gauge or counter to more sophisticated structures like Histograms) - all stored in a registry (map).
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

- Per the Monthly Architect's meeting of 12/13/21 - it was decided to use go-metrics for Go services over creating our own library or using open census.  C services will either find/pick a package that provides similar functionality to go-metrics or implement internally something providing MVP capability.
- Use of go-metrics helps avoid too much service bloat since it is already in most Go services.
- Per the same Monthly Architect's meeting, it as decided to implement metrics in Go services first.

### Implementation Details for Go
The go-metrics package offers the following types of metrics collection:
- Gauges: holds a single integer (int64) value.
    - Example use:  Number of notifications in retry status
    - Operations to update the gauge and get the gauge's value
    - Example code:

``` Go
g := metrics.NewGauge()
g.Update(42)  // set the value to 42
g.Update(10)  // now set the value to 10
fmt.Println(g.Value())  // print out the current value in the gauge = 10
```

- Counter: holds a integer (in64) count.  A counter could be implemented with a Gauge.
    - Example use:  the current store and forward queue size
    - Operations to increment, decrement, clear and get the counter's count (or value)

``` Go
c := metrics.NewCounter()
c.Inc(1)  // add one to the current counter
c.Inc(10) // add 10 to the current counter, making it 11
c.Dec(5)  // decrement the counter by 5, making it 6  
fmt.Println(c.Count())  // print out the current count of the counter = 6
```

- Meter:  measures the rate (int64) of events over time (at one, five and fifteen minute intervals).
    - Example use:  the number or rate of requests on a service API
    - Operations: provide the total count of events as well as the mean and rate at 1, 5, and 15 minute rates

``` Go
m := metrics.NewMeter()
m.Mark(1)  // add one to the current meter value
time.Sleep(15 * time.Second)  // allow some time to go by
m.Mark(1)  // add one to the current meter value
time.Sleep(15 * time.Second)  // allow some time to go by
m.Mark(1)  // add one to the current meter value
time.Sleep(15 * time.Second)  // allow some time to go by
m.Mark(1)  // add one to the current meter value
time.Sleep(15 * time.Second)  // allow some time to go by
fmt.Println(m.Count())  // prints 4
fmt.Println(m.Rate1())  // prints 0.11075889086811593
fmt.Println(m.Rate5())  // prints 0.1755318374350548
fmt.Println(m.Rate15()) // prints 0.19136522498856992
fmt.Println(m.RateMean()) //prints 0.06665062941438574
```

- Histograms: measure the statistical distribution of values (int64 values) in a collection of values.
    - Example use: response times on APIs
    - Operations: update and get the min, max, count, percentile, sample, sum and variance from the collection

``` Go
h := metrics.NewHistogram(metrics.NewUniformSample(4))
h.Update(10)
h.Update(20)
h.Update(30)
h.Update(40)
fmt.Println((h.Max()))  // prints 40
fmt.Println(h.Min())    // prints 10
fmt.Println(h.Mean())   // prints 25
fmt.Println(h.Count())  // prints 4
fmt.Println(h.Percentile(0.25))  //prints 12.5
fmt.Println(h.Variance())  //prints 125
fmt.Println(h.Sample())  //prints &{4 {0 0} 4 [10 20 30 40]}
```
- Timer: measures both the rate a particular piece of code is called and the distribution of its duration
    - Example use:  how often an app service function gets called and how long it takes get through the function
    - Operations:  update and get min, max, count, rate1, rate5, rate15, mean, percentile, sum and variance from the collection

``` Go
t := metrics.NewTimer()
t.Update(10)
time.Sleep(15 * time.Second)
t.Update(20)
time.Sleep(15 * time.Second)
t.Update(30)
time.Sleep(15 * time.Second)
t.Update(40)
time.Sleep(15 * time.Second)
fmt.Println((t.Max()))  // prints 40
fmt.Println(t.Min())    // prints 10
fmt.Println(t.Mean())   // prints 25
fmt.Println(t.Count())  // prints 4
fmt.Println(t.Sum())    // prints 100
fmt.Println(t.Percentile(0.25))  //prints 12.5
fmt.Println(t.Variance())  //prints 125
fmt.Println(t.Rate1())  // prints 0.1116017821771607
fmt.Println(t.Rate5())  // prints 0.1755821073441404
fmt.Println(t.Rate15()) // prints 0.1913711954736821
fmt.Println(t.RateMean()) //prints 0.06665773963998162

```

!!! Note
    The go-metrics package does offer some variants of these like the GaugeFloat64 to hold 64 bit floats.

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