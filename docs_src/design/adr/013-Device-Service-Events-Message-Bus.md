# Device Services Send Events via Message Bus

  * [Status](#status)
  * [Context](#context)
  * [Decision](#decision)
    + [Which Message Bus implementations?](#which-message-bus-implementations-)
    + [Go Device SDK](#go-device-sdk)
    + [C Device SDK](#c-device-sdk)
    + [Core Data and Persistence](#core-data-and-persistence)
    + [V2 Event DTO](#v2-event-dto)
    + [Message Envelope](#message-envelope)
    + [Redis Streams](#redis-streams)
    + [Application Services](#application-services)
    + [Message Bus Topics](#message-bus-topics)
    + [Configuration](#configuration)
      - [Device Services](#device-services)
        * [[MessageQueue]](#-messagequeue-)
      - [Core Data](#core-data)
        * [[MessageQueue]](#-messagequeue--1)
      - [Application Services](#application-services-1)
        * [[MessageBus]](#-messagebus-)
        * [[Binding]](#-binding-)
    + [Secure Connections](#secure-connections)
  * [Consequences](#consequences)

## Status

**proposed**

## Context

This ADR details how device services will send EdgeX Events to other services via the EdgeX Message Bus. This is instead of how they currently send the Events via HTTP to Core Data, which then puts the Events on the Message Bus. 

> *Note: Though this design is centered on device services, it does have cross cutting impacts with other EdgeX services and modules*

> *Note: This ADR is depended on the [**Secret Provider for All**](TBD) to provide the secrets for secure Message Bus connections.*

## Decision

### Which Message Bus implementations?

Multiple Device Services will need to be publishing Events to the Message Bus concurrently, so the `ZMQ` will not be a valid option. This is because `ZMQ` only allows for a single publisher. The `MQTT` and `Redis Streams` are valid option to use with this design as they both support multiple publishers. These are the only other implementations currently available for Go services. The C base device services do not yet have a Message Bus implementation.  See the [C Device SDK](#c-device-sdk) below for details.

### Go Device SDK

The Go Device SDK will take advantage of the existing `go-mod-messaging` module to enable use of the EdgeX Message Bus. A new bootstrap handler will be created which initializes the Message Bus client based on configuration. See [Configuration](#configuration) section below for details.  Bootstrapping will fail if the Message Bus configuration specifies `zero` for the type. This has to be a specific check by for Device Services since `zero` is a valid type in go-mod-messaging. The Go SDK will be enhanced to optionally publish Events to the Message Bus anywhere it currently POSTs Events to Core Data. This publish vs POST option will be controlled by configuration.  See [Configuration](#configuration) section below for details. 

### C Device SDK

The C Device SDK will implement its own Message Bus abstraction similar to the one in `go-mod-messaging` with just the MQTT implementation to start with. Using this abstraction allows for future implementations to be added when use cases warrant the addition.  As with the Go SDK, the C SDK will be enhanced to optionally publish Events to the Message Bus anywhere it currently POSTs Events to Core Data. This publish vs POST option will be controlled by configuration.  See [Configuration](#configuration) section below for details.

### Core Data and Persistence

With this design, Events will be sent directly to Application Services w/o going through Core Data and thus will not be persisted unless changes are made to Core Data. To allow Events to optionally continue to be persisted, Core Data will become a subscriber for the Events from the Message Bus. The Events will be persisted when they are received. Core Data will also retain the ability to receive Events via HTTP, persist them and publish them to the Message Bus as is done today. This allows for the flexibility to have some device services to be configured to POST Events and some to be configured to publish Events while we transition the Device Services to all have the capability to publishing Events. In the future, once this new `Publish` approach has been proven, we may decide to remove POSTing Events to Core Data from the Device SDKs.

### V2 Event DTO

As this development will be part of the Ireland release all Events published to the Message Bus will use the V2 Event DTO. This is already implemented in Core Data for the V2 AddEvent API.

### Message Envelope

EdgeX Go Services currently uses a custom Message Envelope for all data that is published to the Message Bus. This envelope wraps the data with metadata, which is `ContentType` (JSON or CBOR), `Correlation-Id` and the obsolete `Checksum`. The `Checksum` is used when the data is CBOR encoded to identify the Event in V1 API to be mark it as pushed. This checksum is no longer needed as the V2 Event DTO requires the ID be set by the Device Services which will always be used in the V2 API to mark the Events as pushed. The Message Envelope will be updated to remove this property.

The C SDK will also will recreate this Message Envelope.

### Redis Streams

The Redis Streams Message Bus implementation currently only supports password authentication in configuration. There is support in the code for certificates, but it is not exposed via configuration. The implementation may need to be enhanced to include the authentication capabilities described in the **[Secure Connections](#secure-connections)** section below.

### Application Services

As part of the V2 API consumption work in Ireland the App Services SDK will be changed to expect to receive V2 Event DTOs rather than the V1 Event model. It will also be updated to no longer expect or use the `Checksum` currently on the  Message Envelope. Note these changes must occur for the V2 consumption and are not directly tied to this effort. 

The App Service SDK will be enhanced for the secure Message Bus connection described below. See **[Secure Connections](#secure-connections)** for details

### Message Bus Topics

> *Note: The change recommended here is not required for this design, but it provides a good opportunity to adopt it.*

Currently Core Data publishes Events to the simple `events` topic. All Application Services running receive all Events published, whether they want them or not. The Events can be filtered out using the `FilterByDeviceName` pipeline function, but the Application Services still receive all the Events and process all the Events to some extent. This could cause load issues in a deployment with many devices and large volume of Events.

Pub/Sub systems have advanced topic schema, which we can take advantage of to filter for just the Events the Application Service actual needs. If the publishers of Events add the `Device Name` to the topic in the form `edgex/events/<device-name>` then the Application Service can filter for just the Events from the device(s) it wants by only subscribing to those `Device Names`, i.e. `edgex/events/Random-Integer-Device` . If persistence is require, Core Data will subscribe using the `#` wild card, i.e. `edgex/events/#` , so that it receives all Events. 

The Message Bus abstraction allows for multiple subscriptions, so an Application Service could specify to receive data from only specific devices by creating multiple subscriptions. i.e.  `edgex/Events/Random-Integer-Device` and  `edgex/Events/Random-Boolean-Device`. Currently the App SDK only allows for a single subscription topic to be configured, but that could easily be expanded to handle a list of subscriptions. See [Configuration](#configuration) section below for details. 

Core Data's existing publishing of Events would also need to be changed to use this new topic schema. One challenge with this is Core Data doesn't currently know the `Device Name` when it receives a CBOR encoded event. This is because it doesn't decode the Event until after it publishes it to the Message Bus. The V2 API could be enhanced to require the `Device Name` in the HTTP header when content type is CBOR.

### Configuration

#### Device Services

All Device services will have the following additional configuration to allow connecting and publishing to the Message Bus.

##### [MessageQueue]

A  MessageQueue section will be added, which is similar to that used in Core Data today. To enable secure connections, the `Username` & `Password` have been replaced with `Authmode` & `SecretPath`, See **[Secure Connections](#secure-connections)** section below for details. The added `Enabled` property controls whether the Device Service publishes to the Message Bus or POSTs to Core Data. 

```toml
[MessageQueue]
Enabled = true
Protocol = 'tcp'
Host = 'localhost'
Port = 1883
Type = 'mqtt'
PublishTopic = 'edgex/events/<device-name>'
[MessageQueue.Optional]
    # Default MQTT Specific options that need to be here to enable evnironment variable overrides of them
    # Client Identifiers
    ClientId ="<device service key>"
    # Connection information
    Qos          =  "0" # Quality of Sevice values are 0 (At most once), 1 (At least once) or 2 (Exactly once)
    KeepAlive    =  "10" # Seconds (must be 2 or greater)
    Retained     = "false"
    AutoReconnect  = "true"
    ConnectTimeout = "5" # Seconds
    # TLS configuration - Only used if Cert/Key file or Cert/Key PEMblock are specified
    SkipCertVerify = "false"
    Authmode = "none"
    Secretpath = "messagebus"
```

The `PublishTopic` has a placeholder for the `Device Name` which gets replaced with the actual `Device Name`. If the place holder doesn't exist in the configured value, the  `PublishTopic` values  is used as is.

#### Core Data

Core data will also require additional configuration to be able to subscribe to receive Events from the Message Bus.

##### [MessageQueue]

The `MessageQueue` section will be  changed so that the `Topic` property changes to `PublishTopic` and `SubscribeEnabled` and `SubscibeTopic` will be added. As with device services configuration, the `Username` & `Password` have been replaced with `Authmode` & `SecretPath` for secure connections. See **[Secure Connections](#secure-connections)** section below for details. In addition, the Boolean `SubscribeEnabled` property will be used to control if the service subscribes to Events from the Message Bus or not.

```toml
[MessageQueue]
Protocol = 'tcp'
Host = 'localhost'
Port = 1883
Type = 'mqtt'
PublishTopic = 'edgex/events/<device-name>'
SubscribeEnabled = true
SubscibeTopic = 'edgex/events/#'
[MessageQueue.Optional]
    # Default MQTT Specific options that need to be here to enable evnironment variable overrides of them
    # Client Identifiers
    ClientId ="edgex-core-data"
    # Connection information
    Qos          =  "0" # Quality of Sevice values are 0 (At most once), 1 (At least once) or 2 (Exactly once)
    KeepAlive    =  "10" # Seconds (must be 2 or greater)
    Retained     = "false"
    AutoReconnect  = "true"
    ConnectTimeout = "5" # Seconds
    # TLS configuration - Only used if Cert/Key file or Cert/Key PEMblock are specified
    SkipCertVerify = "false"
    Authmode = "none"
    Secretpath = "messagebus"
```

The `PublishTopic` has a placeholder for the `Device Name` which gets replaced with the actual `Device Name`. If the place holder doesn't exist in the configured value, the  `PublishTopic` values  is used as is.

#### Application Services

##### [MessageBus]

Similar to above, the Application Services `MessageBus` configuration will change to allow for secure connection to the Message Bus. The `Username` & `Password` have been replaced with `Authmode` & `SecretPath` for secure connections. See **[Secure Connections](#secure-connections)** section below for details.

```toml
[MessageBus.Optional]
    # MQTT Specific options
    # Client Identifiers
    ClientId ="<app sevice key>"
    # Connection information
    Qos          =  "0" # Quality of Sevice values are 0 (At most once), 1 (At least once) or 2 (Exactly once)
    KeepAlive    =  "10" # Seconds (must be 2 or greater)
    Retained     = "false"
    AutoReconnect  = "true"
    ConnectTimeout = "5" # Seconds
    # TLS configuration - Only used if Cert/Key file or Cert/Key PEMblock are specified
    SkipCertVerify = "false"
    Authmode = "none"
    Secretpath = "messagebus"
```

##### [Binding]

The `Binding` configuration section will require change for the subscribe topic schema describe in the [Message Bus Topics](#message-bus-topics) section above to filter for Events from specific devices. `SubscribeTopic` will change from a string property containing a single topic to the `SubscribeTopics` string property containing a comma separated list of topics. This allows for the flexibility for the property to be a single topic with the `#` wild card so the Application Service receives all Events as it does today.

```toml
[Binding]
Type="messagebus"
SubscribeTopics="edgex/events/Random-Integer-Device, edgex/events/Random-Boolean-Device"
```
or receives all Events as follows:
```toml
[Binding]
Type="messagebus"
SubscribeTopics="edgex/events/#"
```

### Secure Connections

As stated earlier,  this ADR is dependent on the  [**Secret Provider for All**](TBD) ADR to provide a common Secret Provider for all Edgex Services to access their secrets. Once this is available, the Message Bus connection can be secured via the following configurable authentications modes which follows the implementation for secure MQTT Export and secure MQTT Trigger used in Application Services.

- **none** - No authentication used
- **usernamepassword** - Username & password authentication. CA Cert used in conjunction if it exists in the Secret Provider. 
- **clientcert** - Client certificate and key for authentication. CA Cert used in conjunction if it exists in the Secret Provider. 
- **cacert** - CA Certificate only, i.e. just a TLS enabled connection

The secrets specified for the above options are pulled from the `Secret Provider` using the configured `SecretPath`. If the `cacert` secret exists along with the secrets for one of the other modes, it will be used in conjunction to enable a TLS connection in addition to the other mode.

How the secrets are injected into the `Secret Provider` is out of scope for this ADR and covered in the [**Secret Provider for All**](TBD) ADR. 

## Consequences

- If C SDK doesn't support Redis Streams then there must be a MQTT Broker running when a C Device service is in use and configured to use Message Bus.

- If we adopt proposed publish topic with `Device Name` then the V2 API must restrict the characters used in device names to those allowed in a topic.  An [issue](https://github.com/edgexfoundry/go-mod-core-contracts/issues/343) for V2 API already exists for restricting the allowable characters to [RFC 3986](https://tools.ietf.org/html/rfc3986) , which will suffice.
