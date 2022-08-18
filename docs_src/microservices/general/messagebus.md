# EdgeX MessageBus

## Introduction

Edgex has an internal message bus referred to as the **EdgeX MessageBus** , which is used for internal communications between EdgeX services. An EdgeX Service is any Core/Support/App/Device Service from EdgeX or any custom Application or Device Service built with the EdgeX SDKs. 

![[Insert Image of EdgeX MessageBus]](./messagebus diagram.jpg)

The EdgeX MessageBus is meant for internal EdgeX service to service communications. It is not meant as an entry point for external services to communicate with the internal EdgeX services. The eKuiper Rules Engine is an exception to this as it is tightly integrated with EdgeX.

There are EdgeX services that are meant as external entry points, which are:

- **REST API on all the EdgeX services**. 

  Accessed directly in non-secure mode or via the [API Gateway](../../../security/Ch-APIGateway) when running in secure mode

- **App Service using External MQTT Trigger**
  
  An App Service configured to use the [External MQTT Trigger](../../application/Triggers/#external-mqtt-trigger) will accept data from external services on an "external" MQTT connection
  
- **App Service using HTTP Trigger**

  An App Service configured to use the [HTTP Trigger](../../application/Triggers/#http-trigger) will accept data from external services on an "external" REST connection. It is accessed in the same manner as other EdgeX REST APIs.

Originally the EdgeX MessageBus was only used to send *Event/Readings* from Core Data to the Application Services layer. In recent V2 releases more services are now using the EdgeX MessageBus rather than REST for inner service communication. 

- Device Services now publish *Event/Readings* directly to the EdgeX MessageBus rather than sending the *Event/Readings* over REST to Core Data. 
- [Service Metrics](../#service-metrics) are published to the EdgeX MessageBus
- [System Events](../../core/metadata/Ch-Metadata/#device-system-events) are published to the EdgeX MessageBus. 

This trend away from REST to the EdgeX MessageBus for inner service communication continues. The upcoming [North South Messaging](../../../design/adr/0023-North-South-Messaging) implementation will use the EdgeX MessageBus in Core Command and Device Services for command requests and responses. Core Command will also have an external MQTT connection to receive requests from external services. In the future, Device Services will receive Device System Events via the EdgeX MessageBus  rather than the current REST callbacks used when devices are added/updated/deleted in Core Metadata.

## Message Envelope

All messages to be published to the EdgeX MessageBus are wrapped in a `MessageEnvelope`. This envelope contains metadata describing the message payload, such as the payload Content Type (JSON or CBOR) and Correlation Id. The upcoming [North South Messaging](../../../design/adr/0023-North-South-Messaging) implementation will add additional metadata items. 

!!! note
    Unless noted below, the `MessageEnvelope` is  JSON encode when publishing it to the EdgeX MessageBus. This does result in the `MessageEnvelope`'s payload being double encoded.

## Implementations

The EdgeX MessageBus is defined by the message bus abstraction implemented in [go-mod-messaging](https://github.com/edgexfoundry/go-mod-messaging). This module defines an abstract client API which currently has five implementations of the API for the different underlying message bus protocols. Each service that uses the EdgeX MessageBus has a configuration section which defines which implementation to use and how to connect and configure the specific underlying protocol client. This section is  `[Trigger.EdgexMessageBus]` for [Application Services](../../application/GeneralAppServiceConfig) and`[MessageQueue]` for [Core Data](../../core/data/Ch-CoreData/#configuration-properties), [Core Metadata](../../core/metadata/Ch-Metadata/#configuration-properties) and [Device Services](../../device/Ch-DeviceServices/#configuration-properties). The `Type` setting specifies which of the following implementations to use. 

- **Redis Pub/Sub** (**default**) - `Type=redis`
- **MQTT 3.1** - `Type=mqtt`
- **NATS Core** - `Type=nats-core` 
- **NATS JetStream** - `Type=nats-jetstream` 
- **ZeroMQ** (**DEPRECATED**) - `Type=zero` 

!!! note
    I general all EdgeX Services running in a deployment must be configured to use the same EdgeX MessageBus implementation. By default all services that use the EdgeX MessageBus are configured to use the Redis implementation. NATS does support a compatibility mode with MQTT. See the [NATS MQTT Mode](#nats-mqtt-mode) section below for details.

### Redis Pub/Sub

As stated above this is the default implementation that all EdgeX Services are configured to use. It takes advantage of the existing Redis DB instance for the broker. Redis Pub/Sub is a fire and forget protocol, so delivery is not guaranteed. There are no additional configuration options for this implementation. If more robustness is required, use the MQTT or NATS implementations.

!!! example - "Example `MessageQueue` configuration from Core Data using `redis`"
    ```toml
    [MessageQueue]
    Protocol = "redis"
    Host = "localhost"
    Port = 6379
    Type = "redis"
    AuthMode = "usernamepassword"  # required for redis messagebus (secure or insecure).
    SecretName = "redisdb"
    PublishTopicPrefix = "edgex/events/core" # /<device-profile-name>/<device-name>/<source-name> will be added to this Publish Topic prefix
    SubscribeEnabled = true
    SubscribeTopic = "edgex/events/device/#"  # required for subscribing to Events from MessageBus
    ```

### MQTT 3.1

Robust message bus protocol, which has additional configuration options for robustness and requires an additional MQTT Broker to be running. See [MQTT Spec](http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html) for more details on this protocol.

!!! example - "Example `MessageQueue` configuration from Core Data using `mqtt`"
    ```toml
    [MessageQueue]
    Protocol = "mqtt"
    Host = "localhost"
    Port = 1883
    Type = "tcp"
    AuthMode = "none"  # Currently MQTT auth not supported
    PublishTopicPrefix = "edgex/events/core" # /<device-profile-name>/<device-name> will be added to this Publish Topic prefix
    SubscribeEnabled = true
    SubscribeTopic = "edgex/events/device/#"  # required for subscribing to Events from MessageBus
      [MessageQueue.Optional]
      # Default MQTT Specific options that need to be here to enable evnironment variable overrides of them
      # Client Identifiers
      ClientId ="core-data"
      # Connection information
      Qos          =  "0" # Quality of Sevice values are 0 (At most once), 1 (At least once) or 2 (Exactly once)
      KeepAlive    =  "10" # Seconds (must be 2 or greater)
      Retained     = "false"
      AutoReconnect  = "true"
      ConnectTimeout = "5" # Seconds
      CleanSession = "false"
    ```

#### Additional MQTT Options

| Option         | Description                                                  |
| -------------- | ------------------------------------------------------------ |
| ClientId       | Unique name of the client connecting to the MQTT broker      |
| Qos            | Quality of Service level <br />0: At most once delivery<br />1: At least once delivery<br />2: Exactly once delivery<br />See the [MQTT QOS Spec](http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718099) for more details |
| KeepAlive      | Maximum time interval in seconds that is permitted to elapse between the point at which the client finishes transmitting one control packet and the point it starts sending the next. If exceeded, the broker will close the client connection |
| Retained       | If true, Server MUST store the Application Message and its QoS, so that it can be delivered to future subscribers whose subscriptions match its topic name |
| AutoReconnect  | If true, automatically attempts to reconnect to the broker when connection is lost |
| ConnectTimeout | Timeout in seconds for the connection to the broker to be successful |
| CleanSession   | if true, Server MUST discard any previous Session and start a new one. This Session lasts as long as the Network Connection |

### NATS

Description TBD

#### NATS Core

Description TBD

#### NATS JetStream

Description TBD

#### Additional NATS  Options

| Option                  | Description                                                  |
| ----------------------- | ------------------------------------------------------------ |
| ClientId                | Unique name of the client connecting to the NATS Server      |
| Format                  | Format of the actual message published. Valid values are:<br />- **nats** : Metadata from the `MessageEnvlope` are put into the NATS header and the payload from the `MessageEnvlope` is published as is. **Preferred format when all services are using NATS**<br />- **json** : JSON encodes the `MessageEnvelope` and publish it as the message. Use the for compatibility when other services using MQTT 3.1 and running NATS Server in MQTT mode. |
| Durable                 | Description TBD                                              |
| AutoProvision           | Description TBD                                              |
| ConnectTimeout          | Timeout in seconds for the connection to the broker to be successful |
| RetryOnFailedConnect    | Description TBD                                              |
| QueueGroup              | Description TBD                                              |
| Deliver                 | Description TBD                                              |
| DefaultPubRetryAttempts | Description TBD                                              |

#### NATS MQTT Mode

Description TBD

### ZeroMQ (DEPRECATED)

ZeroMQ is a broker-less TCP based message bus protocol. Since it is broker-less, there can only a be a single publisher and many subscribers. Once Device Services also started publishing to the EdgeX MessageBus, ZeroMQ became unusable, thus it has been deprecated and will be removed in the next major release.

## Multi-level topics and wildcards

The EdgeX MessageBus uses multi-level topics and wildcards to allow filtering of data via subscriptions and has standardized on a MQTT like scheme. See [MQTT multi-level topics and wildcards](https://www.hivemq.com/blog/mqtt-essentials-part-5-mqtt-topics-best-practices) for more information.

The Redis implementation converts the Redis Pub/Sub multi-level topic scheme to one similar to MQTT. In Redis Pub/Sub the "**.**" is used as a level separator and the "*" is used as a wildcard. These are converted to "/" and "#" respectively, which are used by MQTT. MQTT additionally uses the "+" as a wildcard for single levels and the "#" for multi-level (only at the end). The Redis implementation uses the "#" for both the single and multi-level wildcard.

!!! note
    The  inconsistency with how the Redis implementation handles multi-level topics and wildcards not being 100% compliant with the MQTT scheme will be resolved in the next major release. 

The NATS implementations convert the NATS multi-level topic scheme to match that of MQTT. In NATS "**.**" is used as a level separator, "*" is used as the single level wildcard and "**>**" is used for the multi-level wild card. These are converted to "/", "+" and "#" respectively, which are compliant with the MQTT scheme.

!!! example - "Example Multi-level topics and wildcards for EdgeX MessageBus - *Redis implementation*"
    - **edgex/events/#**

        All events coming from device services or core data for any device profile, device or source
      
    - **edgex/events/device/#**
    
        All events coming from device services for any device profile, device or source
      
    - **edgex/events/#/#/camera-001/#**
    
        Only events coming from device services or core data for any device profile, but only for the device "camera-001" and for any source
      
    - **edgex/events/device/onvif/#/status**
    
        Only events coming from device services for only the device profile "onvif", and any device and only for the source "status"



!!! example - "Example Multi-level topics and wildcards for EdgeX MessageBus - *MQTT 3.1 and NATS implementations*"
    - **edgex/events/#**

        All events coming from device services or core data for any device profile, device or source
      
    - **edgex/events/device/#**
    
        All events coming from device services for any device profile, device or source
      
    - **edgex/events/+/+/camera-001/#**
    
        Only events coming from device services or core data for any device profile, but only for the device "camera-001" and for any source
      
    - **edgex/events/device/onvif/+/status**
    
        Only events coming from device services for only the device profile "onvif", and any device and only for the source "status"
