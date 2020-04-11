# Core Data

![zoomify](EdgeX_CoreData.png)

## Introduction

The Core Data microservice provides a centralized persistence facility
for data readings collected by devices and sensors. Device services for
devices and sensors that collect data, call on the Core Data service to
store the device and sensor data on the edge system (such as in a
gateway) until the data can be moved "north" and then exported to
Enterprise and cloud systems.

Other services, such as a Scheduling services, within EdgeX Foundry and
potentially outside of EdgeX Foundry, access the device and sensor data
stored on the gateway only through the Core Data service. Core Data
provides a degree of security and protection of the data collected by
devices and sensors while the data is at the edge.

Core Data uses a REST API for moving data into and out of the local
storage. In the future, the microservice could be expandable to allow
data to be accessed via other protocols such as MQTT, AMQP, and so
forth. Core Data moves data to the Export Service layer via ZeroMQ by
default. An alternate configuration of the Core Data microservice allows
the data to be distributed to the Export Services via MQTT, but would
also require the installation of a broker such as ActiveMQ.

The Rules Engine microservice receives its data from the Export
Distribution microservice by default. Where latency or volume are of
concern, an alternate configuration of the Rules Engine microservices
allows it to also get its data directly from Core Data via ZeroMQ (it
becomes a second subscriber to the same Export Services ZeroMQ
distribution channel).

## Core Data "Streaming"

By default, Core Data does persist all data collected by devices and
sensors sent to it. However, when the data is too sensitive to be stored
at the edge, or the need is not present for data at the edge to be used
by other services locally (e.g. by an analytics microservice), the data
can be "streamed" through Core Data without persisting it. A
configuration change to Core Data (persist.data=false) has Core Data
send data to the Export Service, through message queue, without
persisting the data locally. This option has the advantage of reducing
latency through this layer and storage needs at the network edge, but
the cost is having no historical data to use for operations based on
changes over time, and only minimal device actuation decisions, based on
single event data, at the edge.

## Data Model

The following diagram shows the Data Model for Core Data.

![image](EdgeX_CoreDataModel.png)

## Data Dictionary


| Class        | Description                                 |
| --- | --- |
| Event              | <ul><li>ID Device</li><li>Identifier</li><li>Collection of Readings</li><br>Event has a one-to-many relationship with Reading. |      
| Reading            | name-value pair<br>Examples: "temp 62" "rpm 3000"<br>The **value**is an Integer, Decimal, String, or Boolean.<br> The **name**  a value descriptor reference. The value descriptor defines information about the information the Reading should convey. |
| Value Descriptor   | This specifies a folder to put the log files.   |


## High Level Interaction Diagrams

The two following High Level Interaction Diagrams show:

> EdgeX Foundry Core Data add device or sensor readings EdgeX Foundry
> Core Data request event reading or data for a device

**Core Data Add Device or Sensor Readings**

![image](EdgeX_CoreDataAddDevice.png)

**Core Data Request Event Reading or Data for a Device**

![image](EdgeX_CoreDataEventReading.png)

## Configuration Properties

Please refer to the general [Configuration documentation](https://docs.edgexfoundry.org/1.2/microservices/configuration/Ch-Configuration/#configuration) for configuration properties common across all services.

In order to support publishing events via message bus, Core-Data has the following additional configuration section. Changes made to any of these properties while the service is running will not be reflected until the service is restarted.

|Configuration  |     Default Value     |             Dependencies|
| --- | --- | -- |
| **Entries in the MessageQueue section of the configuration allow for publication of events to a message bus** |
|MessageQueue Protocol | tcp | Indicates the connectivity protocol to use to use the bus.|
|MessageQueue Host | * | Indicates the host of the messaging broker, if applicable.|
|MessageQueue Port | 5563 | Indicates the port to use when publishing a message.|
|MessageQueue Type | zero | Indicates the type of messaging library to use. Currently this is ZeroMQ by default. Refer to the [go-mod-messaging](https://github.com/edgexfoundry/go-mod-messaging) module for more information. |
|MessageQueue Topic | events | Indicates the topic to which messages should be published.|
| **The following are additional entries in Writable section applicable to the Core-Data service.** |
|Writable DeviceUpdateLastConnected | false | Indicates whether the "Device Last Connected" timestamp should be updated with each event received from a given device.|
|Writable MetaDataCheck | false | Indicates whether a call to Core-Metadata should be made to check the validity of the device associated with the incoming event.|
|Writable PersistData | true | Indicates whether sensor event data should be persisted to the database. If set to "false", then Core-Data is nothing but a pass-through.|
|Writable ServiceUpdateLastConnected | false | Indicates whether the "Device Service Last Connected" timestamp should be updated with each event received from a given device.|
|Writable ValidateCheck | false | Indicates whether a call to Core-Metadata should be made for validation of value descriptors assigned to each reading in an event.|
|Writable ChecksumAlgo | xxHash | Identifies the algorithm to use when calculating an event's checksum. |
 | | | |