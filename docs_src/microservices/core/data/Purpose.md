---
title: Core Data - Purpose
---

# Core Data - Purpose

The Core Data microservice provides a centralized persistence for data collected by [devices](../../../general/Definitions.md#device).
Device services that collect sensor data call on the core data service to
store the sensor data on the edge system (such as in a [gateway](../../../general/Definitions.md#gateway)) until the data gets moved "north" and then exported to Enterprise and cloud systems. 
Core data persists the data in a local database.  
[PosgreSQL](https://www.postgresql.org/) is used by default, but a database abstraction layer allows for other database implementations to be added.

![image](EdgeX_CoreData.png)

Other services and systems, both EdgeX specific and external, access the sensor data through the core data service.
Core data also provides a degree of security and protection of the data collected while the data is at the edge.

!!! note
    Core data is completely optional. Device services can send data via message bus directly to application services.  If local persistence is not needed, the service can be removed.

If persistence is needed, sensor data can be sent via message bus to core data which then persists the data.  See below for more details.

Sensor data can be sent to core data via two different means:

1. Services (like devices services) and other systems can put sensor data on a message bus topic and core data can be configured to subscribed to that topic.
    This is the default means of getting data to core data.
    Any service (like an application service or rules engine service) or 3rd system could also subscribe to the same topic.
    If the sensor data does not need to persisted locally, core data does not have to subscribe to the message bus topic - making core data completely optional.
    By default, the message bus is implemented using MQTT.  
    MQTT can be used as an alternate message bus implementation.
        ![image](EdgeX_CoreDataSubscriber.png)

2. Services and systems can call on the core data REST API to send data to core data and have the data put in local storage.
   The REST method is an alternative method to send data to core data.
   When data is sent via REST to core data, core data re-publishes the data on to message bus so that other services can subscribe to it.
       ![image](EdgeX_CoreDataRESTEndpoint.png)


Core data moves data to the application service (and [edge analytcs](../../../general/Definitions.md#edge-analytics)) via MQTT by default. MQTT or NATS (opt-in at build time) can alternately be used. 
Use of MQTT requires the use of an MQTT broker like mosquitto.
Use of NATS requires all service to be built with NATS enabled and the installation of NATS Server.  
A messaging infrastructure abstraction is in place that allows for other message bus (e.g., AMQP) implementations to be created and used.