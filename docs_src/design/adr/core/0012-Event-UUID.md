# Event UUID Design

## Status
Proposed

## Context
Today, the Event object does not include an independent and unique identifier.  [Event](https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/models/event.go) does contain the following properties that have been used to identify (or help identify) the Event with mixed results:

- Id: provided by the database when the Event is persisted.  This means the Event would not always have an Id (pre-sending to core or if persistence is turned off)
Used by App Services MarkAsPush function to call Core Data’s MarkAsPushed API. 
- Checksum:  used to hash the CBOR encoded event before publishing the data on the MessageBus for transmission between services (example: between core data and application services)
Used by App Services MarkAsPush function to call Core Data’s MarkAsPushed API when eventId is not available. Passed in the MessageBus’s MessageEnvelope.
- CorrelationId: used to associate the Event into a multi-service transaction; for example, the transaction of sensor data ingestion at a device service all the way to data export at the application service.

Today, these are used in log messages by all services. Passed in either the REST Header or the MessageBus MessageEnvelope.
Use (or misuse) of these properties to uniquely identify an event is problematic, especially when EdgeX looks to operate across more distributed service boundaries, use of more messaging technology, and with the arrangement of services to be more use case driven (ex:  device services sending events directly to application services in the near future).
What is required is a unique identifier for every event, created at the event’s inception (not at the point of persistence) and independent of origin (device service, another application, etc.), technology (database, etc.) and uniquely (universally) able to identify the event in a large scale distributed deployment (perhaps even with multiple instances of EdgeX operating in the environment).

## Proposed Design

!!! Note
    This proposed design would be implemented in **V2 API only**.  The addition, if UUID was a required field, would cause non-backward compatibility issues

Add a UUID property to the Event model object in Go Mod Contracts (https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/models/event.go) and equivalent model concept in the alternate language SDKs (like the C Device Service SDK).

``` go
import "github.com/google/uuid"
type Event struct {
    UUID          uuid.UUID    `json:"uuid,omitempty" codec:"uuid,omitempty"`            
    ID          string    `json:"id,omitempty" codec:"id,omitempty"`            
// …
}
```

On creation of the Event object, from whatever context it is created, the Event UUID property should be immediately populated before transmitting or otherwise used – especially before it is transmitted as part of a request to any other service.  Preferably, the UUID is populated at the time of construction/initialization of the Event.

``` go
func NewEvent() *Event {
    UUID = uuid.New()
}
```

In most circumstances, the Event creation begins when a device service creates a new Event to send sensor readings into Core Data and the rest of EdgeX.  Since the UUID is created on the Event, it does not matter where the event is created.  The UUID should remain with the associated event even when it is persisted.
Core data should include a new query API to get an Event by the UUID (from the associated database).

## Decision

TBD

## Consequences/considerations
-  Functions throughout EdgeX micro services currently using correlation id, checksum, or Event ID to uniquely identify the event would need to switch to use the UUID.
-  Services that create the event object would use the new constructor (thus allowing a different implementation of the unique identifier in the future or by a third party)

## References
- https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/models/event.go
- https://docs.edgexfoundry.org/1.2/microservices/core/data/Ch-CoreData/

