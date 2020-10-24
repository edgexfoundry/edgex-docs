# EdgeX Metrics Collection and Control Plane Eventing

## Status

### Proposed

- design for Ireland
- implementation for Jakarta (stretch for Ireland)

## Context

[System Management services](../../../microservices/system-management/Ch_SystemManagement.md) (SMA and executors) currently provide a limited set of “metrics” to requesting clients (3rd party applications and systems external to EdgeX).  Namely, it provides requesting clients with service CPU and memory usage; both metrics about the resource utilization of the service itself versus metrics that are about what is happening inside of the service.  Arguably, the current system management metrics can be provided by the container engine and orchestration tools (example: by Docker engine) or by the underlying OS tooling.

Going forward, users of EdgeX will want to have more insights – that is more metrics and control plane events – on what is happening in the data collection, device management and monitoring, and event handling processes inside of Edge services.  

### Definitions

**Metric (or telemetry) data** is defined as the count or rate of some action, resource, or circumstance in the EdgeX instance or specific service.  Examples or metrics include:

- the number of EdgeX Events sent from core data to an application service via ZeroMQ
- the number of requests on a service API
- the average time it takes to process a message through an application service
- The number of errors logged by a service

**Control plane events** (CPE) are defined as discrete system or service incidents (or `events`) that occur within an EdgeX instance.  Examples of CPE include:

- a device was provisioned (added to core metadata)
- a service was stopped
- service configuration has changed

Note CPE should not be confused with core data Events.  Core data Events represent a collection (one or more) of sensor/device readings.  Core data Events represent sensing of some measured state of the physical world (temperature, vibration, etc.).  CPE represents the detection of some happening inside of the EdgeX software.

The collection and dissemination of metric data and CPE will require service level instrumentation relevant to capture and send data about relevant EdgeX operations.  EdgeX does not currently offer any service instrumentation.

### Metric and CPE Consumption/Use

At this time, EdgeX will make metric data and CPE available to other subscribing 3rd party applications and systems, but will not necessarily consume or use this information itself.  

In the future, EdgeX may consume its own metric data or CPE.  For example, EdgeX may, in the future,

- use a metric on the number of EdgeX events being sent to core data as the means to throttle back device data collection
- use a configuration change CPE to automatically restart a service.

In the future, EdgeX application services may optionally subscribe to metrics and CPE messages (by attaching to the appropriate message pipe).  Thus allowing additional filtering, transformation, endpoint control of metric and CPE data.

- At the point where this feature is supported, consideration would need to be made as to whether all events (sensor reading messages and metric/CPE messages go through the same application services)

At this time, EdgeX will not persist the metric or CPE data (except as it may be retained as part of message delivery).  Consumers of metric or CPE data are responsible for persisting the data if needed.  Persistence of metric or CPE information may be considered in the future.

In general, EdgeX metrics and CPE are meant to provide external applications and systems better information about what is happening "inside" EdgeX and the devices with which it communicates.

### Requirements

- Services will push specified metrics collected for that service to a specified (by configuration) message endpoint (MQTT topic, 0MQ topic or other EdgeX supported messaging implementation)
  - Use and configuration to target a secure endpoint (MQTTS) must be provided.  As exemplified by application services, there must be the option to use "insecure secrets" or Vault-backed security services when a secure endpoint is desired.
- Services will push all CPE detected for that service to a specified (by configuration) message endpoint.
  - The endpoint for metric and CPE may be the same or different at the user's discretion.
  - Use and configuration to target a secure endpoint (MQTTS) must be provided.  As exemplified by application services, there must be the option to use "insecure secrets" or Vault-backed security services when a secure endpoint is desired.
- All services must document what metrics and CPE they offer.
- Services must provide REST endpoints that respond with what metrics and CPE the service offers (and whether that metric or CPE is currently `on` or `off`).
  - Proposed endpoint format:  /api/v2/metrics and /api/v2/cpe
- Services will have configuration which allows EdgeX system managers to select which metrics and CPE are turned `on` or `off`.
  - When a metric or CPE is turned `off` the service does not collect the metric or monitor for the CPE.  When a metric is turned `on` the service collects and sends the metric to the designated endpoint.  When a CPE is turned `on` the service monitors for the event and sends any detected CPE to the designated endpoint.
  - All metrics collection and CPE monitoring and sending is `off` by default.
  - Metrics collection must be harvested on some appointed schedule.  This could be designated by configuration in the schedule service or done in a way similar to auto events in device services.  *Do we want to dictate this or allow services to implement as they see fit?*
  - CPE is triggered by some happening in the service that the service monitors for and triggers the publishing of a new CPE message when the event occurs.

### Requested Metrics

The following is a list of example metrics and CPE requested by the EdgeX community and adopters for various service areas.  Number metrics would generally be processed in some interval (last 1/5/15 minutes or other defined interval).

#### General

The following metrics apply to all (or most) services.

- Service uptime (time since last service boot)
- Cumulative number API requests succeeded / failed / invalid (2xx vs 5xx vs 4xx)
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
- **CPE** - creation or removal of a new notification subscriber
- **CPE** - creation or removal of a device profile

#### Application Services

- Processing time for a pipeline; latency (measure of time) an event takes to get through an  application service pipeline
- DB access times
- How often are we failing export to be sent to db to be retried at a later time
- What is the current store and forward queue size
- How much data (size in KBs or MBs) of packaged sensor data is being sent to an endpoint (or volume)
- Number of invalid messages that triggered pipeline
- Number of events processed
- **CPE** - client endpoint modified

#### Device Services

- **CPE** - device added / provisioned
- **CPE** - device removed / de-provisioned
- Number of devices managed by this DS
- Device Requests (which may be more informative than reading counts and rates)

#### Security

Security metrics may be more difficult to ascertain as they are cross service metrics.  They may have to be dealt with per service.  Also, true threat detection based on metrics may be a feature best provided by 3rd party based on particular threats and security profile needs.

- Number of logins and login failures per service and within a given time
- Number of secrets accessed per service name
- Count of any accesses and failures to the data persistence layer
- Count of service start and restart attempts
- **CPE** service stop or restart
- **CPE** registration of new devices and services (allowing for future quarantine mechanism)
- **CPE** indication of any new uploading of new CA/import to vault

### Design Proposal

- All services will use/integrate go-mod-messaging (if not already integrated).
- A new metric/CPE model/DTO (Telemetry/Bucket) is required for services to structure the metric or CPE data.  The model/DTO will have similarities to the core event/reading model/DTO.
  - Even though metric and CPE manifest from different circumstances (a scheduled collection versus monitored event in the service), the same model/DTO should be used to represent either.  This simplifies both the publish and subscribe to metrics/CPE data.
  - *Should we use the same Event/Reading structure for metric and CPE messages?  The event/reading structure has some elements (like device and binary value) that would not make sense in a metric/CPE message.  Additionally, the metric or CPE would want to be attributed to the service that created it.*
  - The proposed message structure (DTO) for metrics and CPE (for inclusion in go-mod-core-contracts) is:
  
  ``` go
    type Telemtry struct {
        ID          string            `json:"id,omitempty" codec:"id,omitempty"`
        Service     string            `json:"device,omitempty" codec:"device,omitempty"`  // originating service
        Created     int64             `json:"created,omitempty" codec:"created,omitempty"`
        Modified    int64             `json:"modified,omitempty" codec:"modified,omitempty"`
        Buckets    []Bucket         `json:"readings,omitempty" codec:"buckets,omitempty"`
        Tags        map[string]string `json:"tags,omitempty" codec:"tags,omitempty" xml:"-"`
    }

    type Bucket struct {
        ID            string `json:"id,omitempty" codec:"id,omitempty"`
        Created       int64  `json:"created,omitempty" codec:"created,omitempty"` 
        Modified      int64  `json:"modified,omitempty" codec:"modified,omitempty"`
        Service       string `json:"device,omitempty" codec:"device,omitempty"`
        Name          string `json:"name,omitempty" codec:"name,omitempty"`  // metric or CPE name key
        Value         string `json:"value,omitempty" codec:"value,omitempty"` // metric or CPE value
        ValueType     string `json:"valueType,omitempty" codec:"valueType,omitempty"`
        Description   string `json:"name,omitempty" codec:"description,omitempty"`  // human readable details
    }
  ```

- Proposed endpoint for the REST endpoints that respond with what metrics and CPE the service offers are:  /api/v2/metrics and /api/v2/cpe
- Configuration, not unlike that provided in core data, will specify what message endpoints the metrics and CPE messages should be sent.
  - Proposed configuration for each service for metric and CPE endpoints:

  ``` yaml
    [MetricsMessageQueue]
    Protocol = 'tcp'
    Host = '*'
    Port = 5573
    Type = 'zero'
    Topic = 'metrics'
    [MessageQueue.Optional]
        # Default MQTT Specific options that need to be here to enable environment variable overrides of them
        # Client Identifiers
        Username =""
        Password =""
        ClientId ="service-abc"
        # Connection information
        Qos = "0" # Quality of service values are 0 (At most once), 1 (At least once) or 2 (Exactly once)
        KeepAlive =  "10" # Seconds (must be 2 or greater)
        Retained = "false"
        AutoReconnect  = "true"
        ConnectTimeout = "5" # Seconds
        # TLS configuration - Only used if Cert/Key file or Cert/Key PEMblock are specified
        SkipCertVerify = "false"

    [CPEMessageQueue]
    Protocol = 'tcp'
    Host = '*'
    Port = 5574
    Type = 'zero'
    Topic = 'cpe'
    [MessageQueue.Optional]
        # Default MQTT Specific options that need to be here to enable environment variable overrides of them
        # Client Identifiers
        Username =""
        Password =""
        ClientId ="service-abc"
        # Connection information
        Qos = "0" # Quality of service values are 0 (At most once), 1 (At least once) or 2 (Exactly once)
        KeepAlive =  "10" # Seconds (must be 2 or greater)
        Retained = "false"
        AutoReconnect  = "true"
        ConnectTimeout = "5" # Seconds
        # TLS configuration - Only used if Cert/Key file or Cert/Key PEMblock are specified
        SkipCertVerify = "false"
  ```

- Metrics and CPE collected/monitored and reported by a service will be associated with a name key.  That name key will be used in the configuration to turn `on` the metric or CPE and will be used in the model/DTO when reporting on the metric or CPE. 
- *Should consideration be given to incorporate alternate protocols/standards for metric and CPE such as https://opentelemetry.io/ or https://github.com/statsd/?*
- *Should we provide a standard interface for the function that gets called to create a new CPE*
- *Should we provide a standard interface for the function that gets called by a schedule service (internal or external) to fetch and publish the desired metrics at the appointed time?*
  - *Do we dictate the use of the scheduler service for this or use the internal scheduler approach?*

## Decision

*To be determined*

## Consequences

- Given the potential that each service publish metrics or CPE, 0MQ is an unlikely implementation unless each service uses a different 0MQ pipe (0MQ topics do not allow multiple publishers).  *Given this constraint, should 0MQ implementation be allowed*
- We need to avoid service bloat.  EdgeX is not an enterprise system.  How can we implement in a concise and economical way?
- The existing system management service (and associated executors) shall remain in place for now.  SMA reports on service CPU, memory, configuration and provides the means to start/stop/restart the services.  This is currently outside the scope of the new metric/CPE collection/monitoring.
  - In the future, SMA could be configured to subscribe to the metric/CPE messages and provide those to clients (with REST calls in a pull vs push way).
  - In the future, some of the SMA's functionality around CPU and memory collection as well as configuration reporting could be delegated to the service and removed from the SMA.  However, considerations for how a service collects its own CPU and memory usage in different languages, different environment (container vs native, etc) would have to considered.
  - In the future, 3rd party mechanisms which offer the same capability as SMA may warrant all of SMA irrelevant.
- The existing notifications service serves to send a notification via alternate protocol outside of EdgeX.  This communication service is provided as a generic communication instrument from any micro service and is independent of any type of data or concern.
  - In the future, the notification service could be configured to be a subscriber of the metric/CPE messages and trigger appropriate external notification (via email, SMTP, etc.).

## Reference

