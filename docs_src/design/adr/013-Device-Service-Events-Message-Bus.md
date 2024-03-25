# Device Services Send Events via Message Bus

- [Status](#status)
- [Context](#context)
- [Decision](#decision)
  * [Which Message Bus implementations?](#which-message-bus-implementations)
  * [Go Device SDK](#go-device-sdk)
  * [C Device SDK](#c-device-sdk)
  * [Core Data and Persistence](#core-data-and-persistence)
  * [V2 Event DTO](#v2-event-dto)
    + [Validation](#validation)
  * [Message Envelope](#message-envelope)
  * [Application Services](#application-services)
  * [MessageBus Topics](#messagebus-topics)
  * [Configuration](#configuration)
    + [Device Services](#device-services)
      - [[MessageQueue]](#messagequeue)
    + [Core Data](#core-data)
      - [[MessageQueue]](#messagequeue)
    + [Application Services](#application-services)
      - [[MessageBus]](#messagebus)
      - [[Binding]](#binding)
  * [Secure Connections](#secure-connections)
- [Consequences](#consequences)

## Status

**Approved**

## Context

Currently EdgeX Events are sent from Device Services via HTTP to Core Data, which then puts the Events on the MessageBus after optionally persisting them to the database. This ADR details how Device Services will send EdgeX Events to other services via the EdgeX MessageBus. 

> *Note: Though this design is centered on device services, it does have cross cutting impacts with other EdgeX services and modules*

> *Note: This ADR is dependent on the **Secret Provider for All** (Link TBD) to provide the secrets for secure Message Bus connections.*

## Decision

### Which Message Bus implementations?

Multiple Device Services may need to be publishing Events to the MessageBus concurrently.  `ZMQ` will not be a valid option if multiple Device Services are configured to publish. This is because `ZMQ` only allows for a single publisher. `ZMQ` will still be valid if only one Device Service is publishing Events. The `MQTT` and `Redis Streams` are valid options to use when multiple Device Services are required, as they both support multiple publishers. These are the only other implementations currently available for Go services. The C base device services do not yet have a MessageBus implementation.  See the [C Device SDK](#c-device-sdk) below for details.

> *Note: Documentation will need to be clear when `ZMQ` can be used and when it can not be used.*

### Go Device SDK

The Go Device SDK will take advantage of the existing `go-mod-messaging` module to enable use of the EdgeX MessageBus. A new bootstrap handler will be created which initializes the MessageBus client based on configuration. See [Configuration](#configuration) section below for details.  The Go Device SDK will be enhanced to optionally publish Events to the MessageBus anywhere it currently POSTs Events to Core Data. This publish vs POST option will be controlled by configuration with publish as the default.  See [Configuration](#configuration) section below for details. 

### C Device SDK

The C Device SDK will implement its own MessageBus abstraction similar to the one in `go-mod-messaging`.  The first implementation type (MQTT or Redis Streams) is TBD. Using this abstraction allows for future implementations to be added when use cases warrant the additional implementations.  As with the Go SDK, the C SDK will be enhanced to optionally publish Events to the MessageBus anywhere it currently POSTs Events to Core Data. This publish vs POST option will be controlled by configuration with publish as the default.  See [Configuration](#configuration) section below for details.

### Core Data and Persistence

With this design, Events will be sent directly to Application Services w/o going through Core Data and thus will not be persisted unless changes are made to Core Data. To allow Events to optionally continue to be persisted, Core Data will become an additional or secondary (and optional) subscriber for the Events from the MessageBus. The Events will be persisted when they are received. Core Data will also retain the ability to receive Events via HTTP, persist them and publish them to the MessageBus as is done today. This allows for the flexibility to have some device services to be configured to POST Events and some to be configured to publish Events while we transition the Device Services to all have the capability to publishing Events. In the future, once this new `Publish` approach has been proven, we may decide to remove POSTing Events to Core Data from the Device SDKs.

The existing `PersistData` setting will be ignored by the code path subscribing to Events since the only reason to do this is to persist the Events. 

There is a race condition for `Marked As Pushed` when Core Data is persisting Events received from the MessageBus. Core Data may not have finished persisting an Event before the Application Service has processed the Event and requested the Event be `Marked As Pushed`. It was decided to remove `Mark as Pushed` capability and just rely on time based scrubbing of old Events.


### V2 Event DTO

As this development will be part of the Ireland release all Events published to the MessageBus will use the V2 Event DTO. This is already implemented in Core Data for the V2 AddEvent API.

#### Validation

Services receiving the Event DTO from the MessageBus will log validation errors and stop processing the Event.

### Message Envelope

EdgeX Go Services currently uses a custom Message Envelope for all data that is published to the MessageBus. This envelope wraps the data with metadata, which is `ContentType` (JSON or CBOR), `Correlation-Id` and the obsolete `Checksum`. The `Checksum` is used when the data is CBOR encoded to identify the Event in V1 API to be mark it as pushed. This checksum is no longer needed as the V2 Event DTO requires the ID be set by the Device Services which will always be used in the V2 API to mark the Events as pushed. The Message Envelope will be updated to remove this property.

The C SDK will recreate this Message Envelope.

### Application Services

As part of the V2 API consumption work in Ireland the App Services SDK will be changed to expect to receive V2 Event DTOs rather than the V1 Event model. It will also be updated to no longer expect or use the `Checksum` currently on the  Message Envelope. Note these changes must occur for the V2 consumption and are not directly tied to this effort. 

The App Service SDK will be enhanced for the secure MessageBus connection described below. See **[Secure Connections](#secure-connections)** for details

### MessageBus Topics

> *Note: The change recommended here is not required for this design, but it provides a good opportunity to adopt it.*

Currently Core Data publishes Events to the simple `events` topic. All Application Services running receive every Event published, whether they want them or not. The Events can be filtered out using the `FilterByDeviceName` or `FilterByResourceName` pipeline functions, but the Application Services still receives every Event and process all the Events to some extent. This could cause load issues in a deployment with many devices and large volume of Events from various devices or a very verbose device that the Application Services is not interested in.

> *Note: The current `FilterByDeviceName` is only good if the device name is known statically and the only instance of the device defined by the `DeviceProfileName`. What we really need is `FilterByDeviceProfileName` which allows multiple instances of a device to be filtered for, rather than a single instance as it it now. The V2 API will be adding `DeviceProfileName` to the Events, so in Ireland this  filter will be possible.*

Pub/Sub systems have advanced topic schema, which we can take advantage of from Application Services to filter for just the Events the Application Service actual wants. Publishers of Events must add the `DeviceProfileName`, `DeviceName` and `SourceName` to the topic in the form `edgex/events/<device-profile-name>/<device-name>/<source-name>`. The `SourceName` is the `Resource` or `Command` name used to create the Event. This allows Application Services to filter for just the Events from the device(s) it wants by only subscribing to those `DeviceProfileNames` or the specific `DeviceNames` or just the specific `SourceNames`  Example subscribe topics if above schema is used:

- **edgex/events/#**
  - All Events 
  - Core Data will subscribe using this topic schema
- **edgex/events/Random-Integer-Device/#** 
  - Any Events from devices created from the **Random-Integer-Device** device profile
- **edgex/events/Random-Integer-Device/Random-Integer-Device1** 
  - Only Events from the **Random-Integer-Device1** Device
- **edgex/events/Random-Integer-Device/#/Int16**
  - Any Events with Readings from`Int16` device resource from devices created from the **Random-Integer-Device** device profile. 
- **edgex/events/Modbus-Device/#/HVACValues
  - Any Events with Readings from `HVACValues` device command from devices created from the **Modbus-Device** device profile.

The MessageBus abstraction allows for multiple subscriptions, so an Application Service could specify to receive data from multiple specific device profiles or devices by creating multiple subscriptions. i.e.  `edgex/Events/Random-Integer-Device/#` and  `edgex/Events/Random-Boolean-Device/#`. Currently the App SDK only allows for a single subscription topic to be configured, but that could easily be expanded to handle a list of subscriptions. See [Configuration](#configuration) section below for details. 

Core Data's existing publishing of Events would also need to be changed to use this new topic schema. One challenge with this is Core Data doesn't currently know the `DeviceProfileName` or `DeviceName` when it receives a CBOR encoded event. This is because it doesn't decode the Event until after it has published it to the MessageBus. Also, Core Data doesn't know of `SourceName` at all. The V2 API will be enhanced to change the AddEvent endpoint from `/event` to `/event/{profile}/{device}/{source}` so that `DeviceProfileName`, `DeviceName`, and `SourceName` are always know no matter how the request is encoded.

This new topic approach will be enabled via each publisher's `PublishTopic` having the `DeviceProfileName`, `DeviceName`and `SourceName`  added to the configured `PublishTopicPrefix`

```toml

PublishTopicPrefix = "edgex/events" # /<device-profile-name>/<device-name>/<source-name> will be added to this Publish Topic prefix
```

See [Configuration](#configuration) section below for details. 

### Configuration

#### Device Services

All Device services will have the following additional configuration to allow connecting and publishing to the MessageBus. As describe above in the  [MessageBus Topics](#messagebus-topics) section, the `PublishTopic` will include the `DeviceProfileName` and `DeviceName`.

##### [MessageQueue]

A  MessageQueue section will be added, which is similar to that used in Core Data today, but with `PublishTopicPrefix` instead of `Topic`.To enable secure connections, the `Username` & `Password` have been replaced with ClientAuth & `SecretPath`, See **[Secure Connections](#secure-connections)** section below for details. The added `Enabled` property controls whether the Device Service publishes to the MessageBus or POSTs to Core Data. 

```toml
[MessageQueue]
Enabled = true
Protocol = "tcp"
Host = "localhost"
Port = 1883
Type = "mqtt"
PublishTopicPrefix = "edgex/events" # /<device-profile-name>/<device-name>/<source-name> will be added to this Publish Topic prefix
[MessageQueue.Optional]
    # Default MQTT Specific options that need to be here to enable environment variable overrides of them
    # Client Identifiers
    ClientId ="<device service key>"
    # Connection information
    Qos          =  "0" # Quality of Sevice values are 0 (At most once), 1 (At least once) or 2 (Exactly once)
    KeepAlive    =  "10" # Seconds (must be 2 or greater)
    Retained     = "false"
    AutoReconnect  = "true"
    ConnectTimeout = "5" # Seconds
    SkipCertVerify = "false" # Only used if Cert/Key file or Cert/Key PEMblock are specified
    ClientAuth = "none" # Valid values are: `none`, `usernamepassword` or `clientcert`
    Secretpath = "messagebus"  # Path in secret store used if ClientAuth not `none`
```

#### Core Data

Core data will also require additional configuration to be able to subscribe to receive Events from the MessageBus. As describe above in the  [MessageBus Topics](#messagebus-topics) section, the `PublishTopicPrefix` will have `DeviceProfileName` and `DeviceName` added to create the actual Public Topic.

##### [MessageQueue]

The `MessageQueue` section will be  changed so that the `Topic` property changes to `PublishTopicPrefix` and `SubscribeEnabled` and `SubscribeTopic` will be added. As with device services configuration, the `Username` & `Password` have been replaced with `ClientAuth` & `SecretPath` for secure connections. See **[Secure Connections](#secure-connections)** section below for details. In addition, the Boolean `SubscribeEnabled` property will be used to control if the service subscribes to Events from the MessageBus or not.

```toml
[MessageQueue]
Protocol = "tcp"
Host = "localhost"
Port = 1883
Type = "mqtt"
PublishTopicPrefix = "edgex/events" # /<device-profile-name>/<device-name>/<source-name> will be added to this Publish Topic prefix
SubscribeEnabled = true
SubscribeTopic = "edgex/events/#"
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
    SkipCertVerify = "false" # Only used if Cert/Key file or Cert/Key PEMblock are specified
    ClientAuth = "none" # Valid values are: `none`, `usernamepassword` or `clientcert`
    Secretpath = "messagebus"  # Path in secret store used if ClientAuth not `none`
```

#### Application Services

##### [MessageBus]

Similar to above, the Application Services `MessageBus` configuration will change to allow for secure connection to the MessageBus. The `Username` & `Password` have been replaced with `ClientAuth` & `SecretPath` for secure connections. See **[Secure Connections](#secure-connections)** section below for details.

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
    SkipCertVerify = "false" # Only used if Cert/Key file or Cert/Key PEMblock are specified
    ClientAuth = "none" # Valid values are: `none`, `usernamepassword` or `clientcert`
    Secretpath = "messagebus"  # Path in secret store used if ClientAuth not `none`
```

##### [Binding]

The `Binding` configuration section will require changes for the subscribe topics scheme described in the [MessageBus Topics](#messagebus-topics) section above to filter for Events from specific device profiles or devices. `SubscribeTopic` will change from a string property containing a single topic to the `SubscribeTopics` string property containing a comma separated list of topics. This allows for the flexibility for the property to be a single topic with the `#` wild card so the Application Service receives all Events as it does today.

Receive only Events from the `Random-Integer-Device` and `Random-Boolean-Device` profiles

```toml
[Binding]
Type="messagebus"
SubscribeTopics="edgex/events/Random-Integer-Device, edgex/events/Random-Boolean-Device"
```
Receive only Events from the  `Random-Integer-Device1` from the `Random-Integer-Device` profile

```toml
[Binding]
Type="messagebus"
SubscribeTopics="edgex/events/Random-Integer-Device/Random-Integer-Device1"
```

or receives all Events:

```toml
[Binding]
Type="messagebus"
SubscribeTopics="edgex/events/#"
```

### Secure Connections

As stated earlier,  this ADR is dependent on the  **Secret Provider for All**(Link TBD) ADR to provide a common Secret Provider for all Edgex Services to access their secrets. Once this is available, the MessageBus connection can be secured via the following configurable client authentications modes which follows similar implementation for secure MQTT Export and secure MQTT Trigger used in Application Services.

- **none** - No authentication 
- **usernamepassword** - Username & password authentication. 
- **clientcert** - Client certificate and key for authentication. 
- The secrets specified for the above options are pulled from the `Secret Provider` using the configured `SecretPath`.

How the secrets are injected into the `Secret Provider` is out of scope for this ADR and covered in the **Secret Provider for All**( Link TBD) ADR. 

## Consequences

- If C SDK doesn't support `ZMQ` or `Redis Streams` then there must be a MQTT Broker running when a C Device service is in use and configured to publish to MessageBus.
- Since we've adopted the publish topic scheme with `DeviceProfileName` and `DeviceName` the V2 API must restrict the characters used in device names to those allowed in a topic.  An [issue](https://github.com/edgexfoundry/go-mod-core-contracts/issues/343) for V2 API already exists for restricting the allowable characters to [RFC 3986](https://datatracker.ietf.org/doc/html/rfc3986) , which will suffice.
- Newer ZMQ may allow for multiple publishers. Requires investigation and very likely rework of the ZMQ implementation in go-mod-messaging. **No alternative has been found**.
- **Mark as Push V2 Api** will be removed from Core Data, Core Data Client and the App SDK
- Consider moving App Service Binding to Writable.  (out of scope for this ADR)
