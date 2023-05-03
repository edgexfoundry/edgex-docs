# Core Data

![image](EdgeX_CoreData.png)

## Introduction

The core data micro service provides centralized persistence for data collected by [devices](../../../general/Definitions.md#device). 
Device services that collect sensor data call on the core data service to
store the sensor data on the edge system (such as in a
[gateway](../../../general/Definitions.md#gateway)) until the data gets moved "north" and then exported to
Enterprise and cloud systems.  Core data persists the data in a local database.  [Redis](https://redis.io/) is used by default, but a database abstraction layer allows for other databases to be used.

Other services and systems, both within EdgeX Foundry and outside of EdgeX Foundry, access the sensor data through the core data service. Core data could also provide a degree of security and protection of the data collected while the data is at the edge.

!!! note
    Core data is completely optional. Device services can send data via message bus directly to application services.  If local persistence is not needed, the service can be removed.
    
    If persistence is needed, sensor data can be sent via message bus to core data which then persita the data.  See below for more details.

Sensor data can be sent to core data via two different means:

1. Services (like devices services) and other systems can put sensor data on a message bus topic and core data can be configured to subscribed to that topic.  This is the default means of getting data to core data.  Any service (like an application service or rules engine service) or 3rd system could also subscribe to the same topic.  If the sensor data does not need to persisted locally, core data does not have to subscribe to the message bus topic - making core data completely optional.  By default, the message bus is implemented using Redis Pub/Sub.  MQTT can be used as an alternate message bus implementation.

    ![image](EdgeX_CoreDataSubscriber.png)

2. Services and systems can call on the core data REST API to send data to core data and have the data put in local storage.  Prior to EdgeX 2.0, this was the default and only means to send data to core data.  Today, it is an alternate means to send data to core data.  When data is sent via REST to core data, core data re-publishes the data on to message bus so that other services can subscribe to it. 

    ![image](EdgeX_CoreDataRESTEndpoint.png)


Core data moves data to the application service (and [edge analytcs](../../../general/Definitions.md#edge-analytics)) via Redis Pub/Sub by default. MQTT or NATS (opt-in at build time) can alternately be used.  Use of MQTT requires the installation of a broker such as ActiveMQ. 
Use of NATS requires all service to be built with NATS enabled and the installation of NATS Server.  
A messaging infrastructure abstraction is in place that allows for other message bus (e.g., AMQP) implementations to be created and used.

## Core Data "Streaming"

By default, core data persists all data sent to it by services and other systems. However, when the data is too sensitive to keep at the edge, or there is no use for the data at the edge by other local services (e.g., by an analytics micro service), the data can be "streamed" through core data without persisting it. A
configuration change to core data (Writable.PersistData=false) has core data
send data to the application services without persisting the data. This option has the advantage of reducing
latency through this layer and storage needs at the network edge.  But the cost is having no historical data to use for analytics that need to look back in time to make a decision.

!!! Note
    When persistence is turned off via the PersistData flag, it is off for all devices.  At this time, you cannot specify which device data is persisted and which device data is not.  [Application services](../../application/ApplicationServices.md) do allow filtering of device data before it is exported or sent to another service like the rules engine, but this is not based on whether the data is persisted or not.

!!! Note
    As mentioned, core data is completely optional.  Therefore, if persistence is not needed, and if sensor data is sent from device services directly to application services via message bus, core data can be removed.  In addition to reducing resource utilization (memory and CPU for core data), it also removes latency of throughput as the core data layer can be completely bypassed.  However, if device services are still using REST to send data into the system, core data is the central receiving endpoint and must remain in place; even if persistence is turned off.

## Events and Readings

Data collected from sensors is marshalled into EdgeX event and reading objects (delivered as JSON objects or a binary object encoded as [CBOR](../../../general/Definitions.md#cbor) to core data).  An event represents a collection of one or more sensor readings.  Some sensors or devices are only providing a single value – a single reading - at a time. Other sensors spew multiple values whenever they are read.

An event must have at least one reading.  Events are associated to a sensor or device – the “thing” that sensed the environment and produced the readings.  Readings represent a sensing on the part of a device or sensor.  Readings only exist as part of (are owned by) an event.  Readings are essentially a simple key/value pair of what was sensed (the key - called a [ResourceName](../../../general/Definitions.md#resource)) and the value sensed (the value).  A reading may include other bits of information to provide more context (for example, the data type of the value) for the users of that data.  Consumers of the reading data could include things like user interfaces, data visualization systems and analytics tools.

In the diagram below, an example event/reading collection is depicted.  The event coming from the “motor123” device has two readings (or sensed values).  The first reading indicates that the motor123 device reported the pressure of the motor was 1300 (the unit of measure might be something like PSI).

![image](EdgeX_Event-Reading.png)

The value type property (shown as type above) on the reading lets the consumer of the information know that the value is an integer, base 64.  The second reading indicates that the motor123 device also reported the temperature of the motor was 120 at the same time it reported the pressure (perhaps in degrees Fahrenheit).

## Data Model

The following diagram shows the Data Model for core data.  Device services send Event objects containing a collection or Readings to core data when a device captures a sensor reading.

![image](EdgeX_CoreDataModel.png)

## Data Dictionary

=== "Event"
    |Property|Description|
    |---|---|
    ||Event represents a single measurable event read from a device.  Event has a one-to-many relationship with Reading.|
    |ID|Uniquely identifies an event, for example a UUID.|
    |DeviceName|DeviceName identifies the source of the event; the device's name.|
    |ProfileName|Identifies the name of the device profile associated with the device and corresponding resources collected in the readings of the event.|
    |SourceName|Name of the source request from the device profile (ResourceName or Command) associated to the reading.|
    |Origin|A timestamp indicating when the original event/reading took place.  Most of the time, this indicates when the device service collected/created the event.|
    |Tags|An arbitrary set of labels or additional information associated with the event.  It can be used, for example, to add location information (like GPS coordinates) to the event.|
    |Readings|A collection (one to many) of associated readings of a given event.|
=== "Reading"
    |Property|Description|
    |---|---|
    |ID|Uniquely identifies a reading, for example a UUID.|
    |DeviceName|DeviceName identifies the source of the reading; the device's name.|
    |ProfileName|Identifies the name of the device profile associated with the device and corresponding resource collected in the reading.|
    |Origin|A timestamp indicating when the original event/reading took place.  Most of the time, this indicates when the device service collected/created the event.|
    |ResourceName|ResourceName-Value provide the key/value pair of what was sensed by a device.  ResourceName specifies what was the value collected.  ResourceName should match a device resource name in the device profile.|
    |Value|The sensor data value|
    |ValueType|The type of the sensor data - from a list of allowed value types that includes Bool, String, Uint8, Int8, ...|
    |BinaryValue|Byte array of sensor data when the data captured is not structured; for example an image is captured.  This information is not persisted in the Database and is expected to be empty when retrieving a Reading for the ValueType of Binary.|
    |MediaType|Indicating the type of binary data when collected.|
    |ObjectValue|Complex value of sensor data when the data captured is structured; for example a BACnet date object: `"date":{ "year":2021, "month":8, "day":26, "wday":4 }`.  This is expected to be empty when the Reading for the ValueType is not `Object`.|

## High Level Interaction Diagrams

The two following High Level Interaction Diagrams show:

- How new sensor readings are collected by a device and added as event/readings to core data and the associated persistence store
- How a client (inside or outside of EdgeX) can query for events (in this case by device name)

**Core Data Add Sensor Readings**

![image](EdgeX_CoreDataAddDevice.png)

**Core Data Request Event / Reading for a Device**

![image](EdgeX_CoreDataEventReading.png)

## Configuration Properties

Please refer to the general [Common Configuration documentation](../../configuration/CommonConfiguration.md) for configuration settings common to all services. 
Below are only the additional settings and sections that are specific to Core Data.

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 the `MessageQueue` configuration has been moved to `MessageBus` in [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)

=== "Writable"
    |Property|Default Value|Description|
    |---|---|---|
    ||Writable properties can be set and will dynamically take effect without service restart|
    |LogLevel|INFO|log entry [severity level](https://en.wikipedia.org/wiki/Syslog#Severity_level).  Log entries not of the default level or higher are ignored. |
    |PersistData|true|When true, core data persists all sensor data sent to it in its associated database|
=== "Writable.Telemetry"
    |Property|Default Value|Description|
    |---|---|---|
    |||See `Writable.Telemetry` at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties) for the Telemetry configuration common to all services |
    | Metrics| |Service metrics that Core Data collects. Boolean value indicates if reporting of the metric is enabled.|
    |Metrics.EventsPersisted |  false| Enable/Disable reporting of number of events persisted.|
    |Metrics.ReadingsPersisted | false|Enable/Disable reporting of number of readings persisted.|
    |Tags|`<empty>`|List of arbitrary Core Data service level tags to included with every metric that is reported.  |
=== "Service"
    |Property|Default Value|Description|
    |---|---|---|
    ||| Unique settings for Core Data. The common settings can be found at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)
    | Port | 59880|Micro service port number|
    |StartupMsg |This is the EdgeX Core Data Microservice|Message logged when service completes bootstrap start-up|
=== "Database"
    |Property|Default Value|Description|
    |---|---|---|
    ||| Unique settings for Core Data. The common settings can be found at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)
    |Name|coredata|Database or document store name |
=== "MessageBus.Optional"
    |Property|Default Value|Description|
    |---|---|---|
    ||| Unique settings for Core Data. The common settings can be found at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)
    |ClientId|"core-data|Id used when connecting to MQTT or NATS base MessageBus |
=== "MaxEventSize"
    |Property|Default Value|Description|    
    |---|---|---|
    | MaxEventSize|25000|maximum event size in kilobytes accepted via REST or MessageBus. 0 represents default to system max.|

### V3 Configuration Migration Guide

Coming soon

## API Reference

[Core Data API Reference](../../../api/core/Ch-APICoreData.md)
