# Control Plane Events

## Status

**Draft**

Proposed: 4/4/22

Originally part of the Metrics collection ADRs
- https://github.com/edgexfoundry/edgex-docs/pull/97
- https://github.com/edgexfoundry/edgex-docs/pull/97
- https://github.com/edgexfoundry/edgex-docs/pull/268

Control Plane Events (CPE) were initially proposed as part of the metrics collection ADR as early as March 2020.   You may find discussions relevant to CPE in these ADR and other design/architecture discussions since March 2020. 

## Context

This ADR outlines creation and handling of CPE **for the core metadata service only**.  Future ADRs or simple project decisions to use the same design may provide for CPE in other services.

### Definitions
[Per Metrics Collection ADR](./0006-Metrics-Collection.md)

Metric (or telemetry) data is defined as the count or rate of some action, resource, or circumstance in the EdgeX instance or specific service. Examples of metrics include:

- the number of EdgeX Events sent from core data to an application service
- the number of requests on a service API
- the average time it takes to process a message through an application service
- The number of errors logged by a service

Control plane events (CPE) are defined as events that occur within an EdgeX instance. Examples of CPE include:

- a device was provisioned (added to core metadata)
- a new profile was created (added to core metadata)

CPE should not be confused with core data Events. Core data Events represent a collection (one or more) of sensor/device readings. Core data Events represent sensing of some measured state of the physical world (temperature, vibration, etc.). CPE represents the detection of some happening inside of the EdgeX software.

### Requirements

- To notify a 3rd party system/application of some happening / event inside of EdgeX (one of its services).
- To accomplish this asynchronously and outside the data flow/data plane handled by EdgeX 
- Each service should be able to define its important happenings/events
- The CPE message format should be the same for all CPE
- Need each service to be able to specify the alerts and turn alert sending on/off for that service

## Decision

### Collection and distribution

A service - in this case core metadata - will have a select set of circumstances by which it wants to create and publish a CPE.  This includes, but is not limited to the following types of events:

- a new device is added, updated or removed from core metadata
- a new profile is added, updated or removed from core metadata
- a new device service is added, updated, or removed from core metadata

In general, the add, update or removal (POST, PUT, PATCH, DELETE in REST terms) of any core metadata object will trigger the creation and publication of a CPE.

When metadata decides to publish a CPE, it will create a CPE message (see below) about the event and push it onto the EdgeX internal message bus (to a topic reserved for CPE).

Support notifications micro service will subscribe to the CPE topic(s).  On receipt of a new CPE, the notifications service will then publish the CPE through its notifications handler to those other services or 3rd party applications subscribed for CPE via existing means (REST or email today; additional alerting means like SMS or MQTT message could be added in the future).

!!! Note
        Support notifications is not set up for subscribing to the EdgeX internal message bus today.  It will need to use go-mod-messaging and subscribe to CPE message bus topics going forward.  On receipt of a CPE message, the support notification service will need to pull the CPE off the topic, format a notification message to then post into the Notifications Handler (see image of current support notifications architecture below for reference).

        ![image](../../microservices/support/notifications/EdgeX_SupportingServicesAlertsArchitecture.png) 

Other services or 3rd party applications/systems will need to subscribe for CPE events via the existing support notifications REST API.  Small changes/additions to the support notifications service may be necessary in order to support this new type of notification.  As an example, a new category (used to specify the type or category of notification or subscription) may need to be added.  These are small implementation details that will be handled in development. 

### CPE Message 

The message for a core metadata CPE will be in JSON form when pushed to the internal EdgeX message bus.

The message for a core metadata CPE will contain the following bits of information:

- type or name of the object by name that was added, changed, etc..  This includes the following types: device, service, profile, etc..  This should follow the callback pattern to specify the type interface.
- what happened.  That is what operation (such as add, update, delete, ...) occurred on the object.
- the originating service (this will always be metadata for this ADR implementation but may include other services in the future).
- timestamp ( the time of the operation that occurred and it should be retrieved from operational message causing the CPE - for example, from the add profile REST request )
- key/value tags for any ancillary information deemed important to the monitor of the CPE.

### Configuration

Core metadata will need configuration on where to publish CPE events (which message bus and message topic).  This is an implementation detail, but it should incorporate service, type and operation indicators in the topic name (ex:  edgex/cpe/[service]/[type]/[operation]).

Core metadata will also need configuration allowing the user to turn CPE sending on or off (off by default).  This on/off toggle should be in the writable section of configuration.
Support notifications will need configuration to be able to connect to the EdgeX internal message bus and details of which topic(s) to subscribe to and watch.

## Considerations

Alternative implementations were considered.

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

The decision to use te notification service is documented above.
Use of the EdgeX message bus will be used with the notification service.  But just pushing CPE onto the message bus does not handle the means to getting the CPE to outside services or applications.  The notification service is well suited to do that.

Use of another framework/package would require yet another package (concerns about package size since most are not for edge) and the fact that it is not inline with existing thoughts/use of the EdgeX message bus.





