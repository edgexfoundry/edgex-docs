# EdgeX Metrics Collection

## Status

**Approved** 
Original proposal 10/24/2020
Approved by the TSC on 3/2/22

**Metric (or telemetry) data** is defined as the count or rate of some action, resource, or circumstance in the EdgeX instance or specific service.  Examples of metrics include:

- the number of EdgeX Events sent from core data to an application service
- the number of requests on a service API
- the average time it takes to process a message through an application service
- The number of errors logged by a service

**Control plane events** (CPE) are defined as `events` that occur within an EdgeX instance.  Examples of CPE include:

- a device was provisioned (added to core metadata)
- a service was stopped
- service configuration has changed

CPE should not be confused with core data Events.  Core data Events represent a collection (one or more) of sensor/device readings.  Core data Events represent sensing of some measured state of the physical world (temperature, vibration, etc.).  CPE represents the detection of some happening inside of the EdgeX software.

This ADR outlines ** metrics (or telemetry) ** collection and handling.

!!! Note
    This ADR initially incorporated metrics collection and control plane event processing.  The EdgeX architects felt the scope of the design was too large to cover under one ADR.  Control plane event processing will be covered under a separate ADR in the future.

## Context

[System Management services](about:blank) (SMA and executors) currently provide a limited set of “metrics” to requesting clients (3rd party applications and systems external to EdgeX).  Namely, it provides requesting clients with service CPU and memory usage; both metrics about the resource utilization of the service (the executable) itself versus metrics that are about what is happening inside of the service.  Arguably, the current system management metrics can be provided by the container engine and orchestration tools (example: by Docker engine) or by the underlying OS tooling.

!!! Info
    The SMA has been deprecated (since Ireland release) and will be removed in a future, yet named, release.

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

In the future, EdgeX may consume its own metric data.  For example, EdgeX may, in the future, use a metric on the number of EdgeX events being sent to core data (or app services) as the means to throttle back device data collection.

In the future, EdgeX application services may optionally subscribe to a service's metrics messages bus (by attaching to the appropriate message pipe for that service).  Thus allowing additional filtering, transformation, endpoint control of metric data from that service.  At the point where this feature is supported, consideration would need to be made as to whether all events (sensor reading messages and metric messages) go through the same application services.

At this time, EdgeX will not persist the metric data (except as it may be retained as part of a message bus subsystem such as in an MQTT broker).  Consumers of metric data are responsible for persisting the data if needed, but this is external to EdgeX.  Persistence of metric information may be considered in the future based on requirements and adopter demand for such a feature.

In general, EdgeX metrics are meant to provide internal services and external applications and systems better information about what is happening "inside" EdgeX services and the associated devices with which it communicates.

### Requirements

- Services will push specified metrics collected for that service to a specified (by configuration) message endpoint (as supported by the EdgeX  message bus implementation; currently either Redis Pub/Sub or MQTT implementations are supported)
    - Each service will have configuration that specifies a message endpoint for the service metrics.  The metrics message topic communications may be secured or unsecured (just as application services provide the means to export to secured or unsecured message pipes today).
    - The configuration will be placed in the `Writable` area.  When a user wishes to change the configuration dynamically (such as turning on/off a metric), then Consul's UI can be used to change it.
- Services will have configuration which indicates what metrics are available from the service.
- Services will have configuration which allows EdgeX system managers to select which metrics are `on` or `off` - in other words providing configuration that determines what metrics are collected and reported by default.
    - When a metric is turned `off` (the default setting) the service does not report the metric.  When a metric is turned `on` the service collects and sends the metric to the designated message topic.
    - Metrics collection must be pushed to the designated message topic on some appointed schedule.  The schedule would be designated by configuration and done in a way similar to auto events in device services.
    - For the initial implementation, there will be just one scheduled time when all metrics will be collected and pushed to the designated message topic.  In the future, there may be a desire to set up a separate schedule for each metric, but this was deemed too complex for the initial implementation.

!!! Info
    Initially, it was proposed that metrics be associated with a "level" and allow metrics to be turned on or off by level (like levels associated to log messages in logging).  The level of metrics data seems arbitrary at this time and considered too complex for initial implementation.  This may be reconsidered in a future release and based on new requirements/use cases.

    It was also proposed to categorize or label metrics - essentially allowing grouping of various metrics.  This would allow groups of metrics to be turned on or off, and allow metrics to be organized per the group when reporting.  At this time, this feature is also considered beyond the scope of the initial implementation and to be reconsidered in a future release based on requirements/use case needs.

    It was also proposed that each service offer a REST API to provide metrics collection information (such as which metrics were being collected) and the ability to turn the collection on or off dynamically.  This is deemed out of scope for the first implementation and may be brought back if there are use case requirements / demand for it. 

### Requested Metrics

The following is a list of example metrics requested by the EdgeX community and adopters for various service areas.  Again, metrics would generally be collected and pushed to the message topic in some configured interval (example: 1/5/15 minutes or other defined interval).  This is just a sample of metrics thought relevant by each work group.  It may not reflect the metrics supported by the implementation.  The exact metrics collected by each service will be determined by the service implementers (or SDK implementers in the case of the app functions and device service SDKs).

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
    It is envisioned that there may be additional specific metrics for each device service.  For example, the ONVIF camera device service may report number of times camera tampering was detected. 

#### Security

Security metrics may be more difficult to ascertain as they are cross service metrics.  Given the nature of this design (on a per service basis), global security metrics may be out of scope or security metrics collection has to be copied into each service (leading to lots of duplicate code for now).  Also, true threat detection based on metrics may be a feature best provided by 3rd party based on particular threats and security profile needs.

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

- **Example metric message body with a single value**

    ``` json
    {"name":"service-up", "value":"120", "timestamp":"1602168089665570000", "tags":{"service":"coredata","uom":"days","type":"int64"}}
    ```

- **Example metric message body with multiple values**

    ``` json
    {"name":"api-requests", "value":"24", "timestamp":"1602168089665570001", "tags":{"service":"coredata","uom":"count","type":"int64", "mean":"0.0665", "rate1":"0.111", "rate5":"0.150","rate15":"0.111"}}
    ```

!!! Info
    The key or metric name must be unique when using go-metrics as it requires the metric name to be unique per the registry.  Metrics are considered immutable.

#### Configuration

Configuration, not unlike that provided in core data or any device service, will specify the message bus type and locations where the metrics messages should be sent.  In fact, the message bus configuration will use (or reuse if the service is already using the message bus) the common message bus configuration as defined below.

**Common configuration** for each service for message queue configuration (inclusive of metrics):

``` yaml
[MessageQueue]
Protocol = 'redis'  ## or 'tcp'
Host = 'localhost'
Port = 5573
Type = 'redis'  ## or 'mqtt'
PublishTopicPrefix = "edgex/events/core" # standard and existing core or device topic for publishing  
  [MessageQueue.Optional]
  # Default MQTT Specific options that need to be here to enable environment variable overrides of them
  # Client Identifiers
  ClientId = "device-virtual"
  # Connection information
  Qos = "0" # Quality of Service values are 0 (At most once), 1 (At least once) or 2 (Exactly once)
  KeepAlive = "10" # Seconds (must be 2 or greater)
  Retained = "false"
  AutoReconnect = "true"
  ConnectTimeout = "5" # Seconds
  SkipCertVerify = "false" # Only used if Cert/Key file or Cert/Key PEMblock are specified
```

Additional configuration must be provided in each service to provide metrics / telemetry specific configuration.  This area of the configuration will likely be different for each type of service.

**Additional metrics collection configuration** to be provided include: 

- Trigger the collection of telemetry from the metrics cache and sending it into the appointed message bus.
- Define which metrics are available and which are turned `off` and `on`.  All are false by default.  The list of metrics can and likely will be different per service.  The keys in this list are the metric name.  True and false are used for `on` and `off` values.
- Specify the metrics topic prefix where metrics data will be published to (ex:  providing the prefix /edgex/telemetry/topic name where the service and metric name `[service-name]/[metric-name]` will be appended per metric (allowing subscribers to filter by service or metric name)

These metrics configuration options will be defined in the `Writable` area of `configuration.toml` so as to allow for dynamic changes to the configuration (when using Consul).  Specifically, the `[Writable].[Writable.Telemetry]` area will dictate metrics collection configuration like this:

``` yaml
[[Writable]]
    [[Writable.Telemetry]]
    Interval = "30s"
    PublishTopicPrefix  = "edgex/telemetry" # /<service-name>/<metric-name> will be added to this Publish Topic prefix
    #available metrics listed here.  All metrics should be listed off (or false) by default
    service-up = false
    api-requests = false
```

!!! Info
    It was discussed that in future EdgeX releases, services may want separate message bus connections.  For example one for sensor data and one for metrics telemetry data.  This would allow the QoS and other settings of the message bus connection to be different. This would allow sensor data collection, for example, to be messaged with a higher QoS than that of metrics.  As an alternate approach, we could modify go-mod-messaging to allow setting QoS per topic (and thereby avoid multiple connections).  For the initial release of this feature, the service will use the same connection (and therefore configuration) for metrics telemetry as well as sensor data.  

#### Library Support

Each service will now need go-mod-messaging support (for GoLang services and the equivalent for C services).  Each service would determine when and what metrics to collect and push to the message bus, but will use a common library chosen for each EdgeX language supported (Go or C currently)

Use of [go-metrics](https://github.com/rcrowley/go-metrics) (a GoLang library to publish application metrics) would allow EdgeX to utilize (versus construct) a library utilized by over 7 thousand projects.  It provides the means to capture various types of metrics in a registry (a sophisticated map).  The metrics can then be published (`reported`) to a number of well known systems such as InfluxDB, Graphite, DataDog, and Syslog.  go-metrics is a Go library made from original Java package https://github.com/dropwizard/metrics.

A similar package would need to be selected (or created) for C.  Per the Core WG meeting of 2/24/22 - it is important to provide an implementation that is the same in Go or C.  The adopter of EdgeX should not see a difference in whether the metrics/telemetry is collected by a C or Go service.  Configuration of metrics in a C or Go service should have the same structure.  The C based metrics collection mechanism in C services (specifically as provided for in our C device service SDK) may operate differently "under the covers" but its configuration and resulting metrics messages on the EdgeX message bus must be formatted/organized the same.

** Considerations in the use of go-metrics **

- This is a Golang only library.  Using this library would not provide with any package to use for the C services.  If there are expectations for parity between the services, this may be more difficult to achieve given the features of go-metrics.
- go-metrics will still require the EdgeX team to develop a bootstrapping apparatus to take the metrics configuration and register each of the metrics defined in the configuration in go-metrics.
- go-metrics would also require the EdgeX team to develop the means to periodically extract the metrics data from the registry and ship it via message bus (something the current go-metrics library does not do).
- While go-metrics offers the ability for data to be reported to other systems, it would required EdgeX to expose these capabilities (possibly through APIs) if a user wanted to export to these subsystems in addition to the message bus.
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

- Should consideration be given to allow metrics to be placed in different topics per name?  If so, we will have to add to the topic name like we do for device name in device services?
    - A future consideration
- Should consideration be given to incorporate alternate protocols/standards for metric collection such as https://opentelemetry.io/ or https://github.com/statsd/?
    - Go metrics is already a library pulled into all Go services.  These packages may be used in C side implementations.

## Decision

- Per the Monthly Architect's meeting of 12/13/21 - it was decided to use go-metrics for Go services over creating our own library or using open census.  C services will either find/pick a package that provides similar functionality to go-metrics or implement internally something providing MVP capability.
- Use of go-metrics helps avoid too much service bloat since it is already in most Go services.
- Per the same Monthly Architect's meeting, it as decided to implement metrics in Go services first.
- Per the Monthly Architect's meeting of 1/24/22 - it was decided not to support a REST API on all services that would provide information on what metrics the service provides and the ability to turn them on / off.  Instead, the decision was to use `Writable` configuration and allow Consul to be the means to change the configuration (dynamically).  If an adopter chooses not to use Consul, then the configuration with regard to metrics collection, as with all configuration in this circumstance, would be static.  If an external API need is requested in the future (such as from an external UI or tool), a REST API may be added.  See older versions of this PR for ideas on implementation in this case.
- Per Core Working Group meeting of 2/24/22 (and in many other previous meetings on this ADR) - it was decided that the EdgeX approach should be one of push (via message bus/MQTT) vs. pull (REST API). Both approaches require each service to collect metric telemetry specific to that service.  After collecting it, the service must either *push* it onto a message topic (as a message) or cache it (into memory or some storage mechanism depending on whether the storage needs to be durable or not) and allow for a REST API call that would cause the data to be *pulled* from that cache and provided in a response to the REST call.  Given both mechanisms require the same collection process, the belief is that *push* is probably preferred today by adopters.  In the future, if highly desired, a *pull* REST API could be added (along with a decision on how to cache the metrics telemetry for that pull). 
- Per Core Working Group meeting of 2/24/22 - **importantly**, EdgeX is just making the metrics telemetry available on the internal EdgeX message bus.  An adopter would need to create something to pull the data off this bus to use it in some way.  As voiced by several on the call, it is important for the adopter to realize that today, "we (EdgeX) are not providing the last mile in metrics data".  The adopter must provide that last mile which is to pick the data from the topic, make it available to their systems and do something with it.
- Per Core Working Group meeting of 2/24/22 (and in many other previous meetings on this ADR) - it was decided not to use Prometheus (or Prometheus library) as the means to provide for metrics.  The reasons for this are many:
    - Push vs pull is favored in the first implementation (see point above).  Also see [similar debate online](https://thenewstack.io/exploring-prometheus-use-cases-brian-brazil) for the pluses/minuses of each approach.
    - EdgeX wants to make telemetry data available without dictating the specific mechanism for making the data more widely available.  Specific debate centered on use of Prometheus as a popular collection library (to use inside of services to collect the data) as well as a monitoring system to watch/display the data.  While Prometheus is popular open source approach, it was felt that many organizations choose to use InfluxDB/Grafana, DataDog, AppDynamics, a cloud provided mechanism, or their own home-grown solution to collect, analyse, visualize and otherwise use the telemetry.  Therefore, rather than dictating the selection of the monitoring system, EdgeX would simply make the data available whereby and organization could choose their own monitoring system/tooling.  It should be noted that the EdgeX approach merely makes the telemetry data available by message bus.  A Prometheus approach would provide collection as well as backend system to otherwise collect, analyse, display, etc. the data.  Therefore, there is typically work to be done by the adopter to get the telemetry data from the proposed EdgeX message bus solution and do something with it.
    - There are some `reporters` that come with go-metrics that allow for data to be taken directly from go-metrics and pushed to an intermediary for Prometheus and other monitoring/telemetry platforms as referenced above.  These capabilities may not be very well supported and is beyond the scope of this EdgeX ADR.  However, even without `reporters`, it was felt a relatively straightforward exercise (on the part of the adopter) to create an application that listens to the EdgeX metrics message bus and makes that data available via *pull* REST API for Prometheus if desired.
    - The Prometheus client libraries would have to be added to each service which would bloat the services (although they are available for both Go an C).  The benefit of using go-metrics is that it is used already by Hashicorp Consul (so already in the Go services).

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
    - EdgeX doesn't yet have global config so this will have to be by service.
- Given the potential that each service publishes metrics to the same message topic, 0MQ is not implementation option unless each service uses a different 0MQ pipe (0MQ topics do not allow multiple publishers).  
    - Like the DS to App Services implementation, do we allow 0MQ to be used, but only if each service sends to a different 0MQ topic?  Probably not.
- We need to avoid service bloat.  EdgeX is not an enterprise system.  How can we implement in a concise and economical way?
    - Use of Go metrics helps on the Go side since this is already a module used by EdgeX modules (and brought in by default).  Care and concern must be given to not cause too much bloat on the C side.
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
