# Control Plane Events

## Status

**Draft**

Originally part of the Metrics collection ADRs
https://github.com/edgexfoundry/edgex-docs/pull/97
https://github.com/edgexfoundry/edgex-docs/pull/97
https://github.com/edgexfoundry/edgex-docs/pull/268

Control Plane Events (CPE) were initially proposed as part of the metrics collection ADR as early as March 2020.   You may find discussions relevant to CPE in these ADR and other design/architecture discussions since March 2020. 

## Definitions
[Per Metrics Collection ADR](./0006-Metrics-Collection.md)

Metric (or telemetry) data is defined as the count or rate of some action, resource, or circumstance in the EdgeX instance or specific service. Examples of metrics include:

- the number of EdgeX Events sent from core data to an application service
- the number of requests on a service API
- the average time it takes to process a message through an application service
- The number of errors logged by a service

Control plane events (CPE) are defined as events that occur within an EdgeX instance. Examples of CPE include:

- a device was provisioned (added to core metadata)
- a service was stopped
- service configuration has changed

CPE should not be confused with core data Events. Core data Events represent a collection (one or more) of sensor/device readings. Core data Events represent sensing of some measured state of the physical world (temperature, vibration, etc.). CPE represents the detection of some happening inside of the EdgeX software.

This ADR outlines creation and handling of CPE.

## Requirements

- To notify a 3rd party system/application of some happening / event inside of EdgeX (one of its services).
- To accomplish this asynchronously and outside the data flow/data plane handled by EdgeX 
- Each service should be able to define its important happenings/events
- The CPE message format should be the same for all CPE
- Need each service to be able to specify the alerts and turn alert sending on/off for that service

**??? Other requirements ???**
- do we care/dictate about how alerts are sent to 3rd party
- do we care/dictate about acknowledgement
- do we care/dictate about escalation

## Design Considerations

### Collection and distribution

- Use the notifications service to receive and send CPE (allows 3rd party systems to register for CPE of choice)
    - already comes with concepts of subscription, retries, escalation, etc.
    - already provides eMail and REST distribution means.  Could be easily extended to send via MQTT, SMS, etc.
    - other services currently send notification via REST, but could outfit notifications with message bus listener and receive notifications via message bus (and other services send via message bus)
    - when not needed, allows entire alerting capability to not be running (reduce size of deployment)
- Use EdgeX message bus
    - alerting is just another message sent on the bus (like metrics collection or the events/readings)
    - would require 3rd parties to subscribe to internal EdgeX message bus or have another service/application subscribe and send to 3rd party
- Use open-source alerting framework/package
    - ex: [goalert](http://goalert.me)

### CPE Message 

- assume JSON in form
- reuse Metrics format?
- what should the CPE message contain?
    - name
    - condition / description of situation causing the alert
    - severity?? (Info, Warning, Error, etc. or others)
    - originating service
    - timestamp
    - tags to add other info

### Configuration

Will depend largely on overarching design 

#### Service Configuration
- need means to shutoff sending alerts (on by default)
- need configuration to get connected with alerting infrastructure (be it message bus, notification service, etc.)

### Client Libraries

We'll need Go and C client libraries or modules to easily incorporate sending of alerts from each service.



