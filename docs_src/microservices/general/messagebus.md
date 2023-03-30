# EdgeX MessageBus

## Introduction

EdgeX has an internal message bus referred to as the **EdgeX MessageBus** , which is used for internal communications between EdgeX services. An EdgeX Service is any Core/Support/Application/Device Service from EdgeX or any custom Application or Device Service built with the EdgeX SDKs. 

The following diagram shows how each of the EdgeX Service use the EdgeX MessageBus.

![[Insert Image of EdgeX MessageBus]](./messagebus diagram.jpg)

The EdgeX MessageBus is meant for internal EdgeX service to service communications. It is not meant as an entry point for external services to communicate with the internal EdgeX services. The eKuiper Rules Engine is an exception to this as it is tightly integrated with EdgeX.

The EdgeX services intended as external entry points are:

- **REST API on all the EdgeX services** - Accessed directly in non-secure mode or via the [API Gateway](../../../security/Ch-APIGateway) when running in secure mode

- **App Service using External MQTT Trigger** - An App Service configured to use the [External MQTT Trigger](../../application/Triggers/#external-mqtt-trigger) will accept data from external services on an "external" MQTT connection
  
- **App Service using HTTP Trigger** - An App Service configured to use the [HTTP Trigger](../../application/Triggers/#http-trigger) will accept data from external services on an "external" REST connection. Accessed in the same manner as other EdgeX REST APIs.

- **App Service using Custom Trigger** - An App Service configured to use a [Custom Trigger](../../application/Triggers/#custom-trigger) can accept data from external services or over additional protocols with few limitations. See [Custom Trigger Example](https://github.com/edgexfoundry/edgex-examples/tree/{{latest_released_version}}/application-services/custom/custom-trigger) for an example.

- **Core Command External MQTT Connection** - Core Command now receives command requests and publishes responses via an external MQTT connection that is separate from the EdgeX MessageBus. The requests are forwarded to the EdgeX MessageBus and the corresponding responses are forwarded back to the external MQTT connection. 

Originally the EdgeX MessageBus was only used to send *Event/Readings* from Core Data to the Application Services layer. In recent V2 releases more services are now using the EdgeX MessageBus rather than REST for inner service communication. 

- Device Services publish *Event/Readings* directly to the EdgeX MessageBus rather than sending them via REST to Core Data. 
- [Service Metrics](../#service-metrics) are published to the EdgeX MessageBus
- [System Events](../../core/metadata/Ch-Metadata/#device-system-events) are published to the EdgeX MessageBus. 
- [Command Request/Reponses](../../../design/adr/0023-North-South-Messaging) are now published to the EdgeX MessageBus by Core Command and Devices Services.  

This trend away from REST to the EdgeX MessageBus for inner service communication continues. In the future, Device Services will receive Device System Events via the EdgeX MessageBus  rather than the current REST callbacks used when devices are added/updated/deleted in Core Metadata.

## Message Envelope

All messages published to the EdgeX MessageBus are wrapped in a `MessageEnvelope`. This envelope contains metadata describing the message payload, such as the payload Content Type (JSON or CBOR), Correlation Id, etc. 

!!! note
    Unless noted below, the `MessageEnvelope` is  JSON encoded when publishing it to the EdgeX MessageBus. This does result in the `MessageEnvelope`'s payload being double encoded.

## Implementations

The EdgeX MessageBus is defined by the message bus abstraction implemented in [go-mod-messaging](https://github.com/edgexfoundry/go-mod-messaging). This module defines an abstract client API which currently has five implementations of the API for the different underlying message bus protocols. 

### Common Configuration

Each service that uses the EdgeX MessageBus has a configuration section which defines which implementation to use and how to connect and configure the specific underlying protocol client. This section is  `[Trigger.EdgexMessageBus]` for [Application Services](../../application/GeneralAppServiceConfig) and`[MessageQueue]` for [Core Data](../../core/data/Ch-CoreData/#configuration-properties), [Core Metadata](../../core/metadata/Ch-Metadata/#configuration-properties) and [Device Services](../../device/Ch-DeviceServices/#configuration-properties). The `Type` setting specifies which of the following implementations to use. 

- **Redis Pub/Sub** (**default**) - `Type=redis`
- **MQTT 3.1** - `Type=mqtt`
- **NATS Core** - `Type=nats-core` 
- **NATS JetStream** - `Type=nats-jetstream` 

!!! note
    In general all EdgeX Services running in a deployment must be configured to use the same EdgeX MessageBus implementation. By default all services that use the EdgeX MessageBus are configured to use the Redis Pub/Sub implementation. NATS does support a compatibility mode with MQTT. See the [NATS MQTT Mode](#nats-mqtt-mode) section below for details.

### Redis Pub/Sub

As stated above this is the default implementation that all EdgeX Services are configured to use. It takes advantage of the existing Redis DB instance for the broker. Redis Pub/Sub is a fire and forget protocol, so delivery is not guaranteed. If more robustness is required, use the MQTT or NATS implementations.

#### Configuration

See [Common Configuration](#common-configuration) section above for the common configuration elements for all implementations.

##### Security Configuration 

| Option     | Default Value      | Description                                                  |
| ---------- | ------------------ | ------------------------------------------------------------ |
| AuthMode   | `usernamepassword` | Mode of authentication to use. Values are `none`, `usernamepassword`<br />, `clientcert`, or `cacert` |
| SecretName | `redisb`           | Secret name used to look up credentials in the service's SecretStore |

##### Additional Configuration

This implementation does not have any additional configuration.

### MQTT 3.1

Robust message bus protocol, which has additional configuration options for robustness and requires an additional MQTT Broker to be running. See [MQTT Spec](http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html) for more details on this protocol.

#### Configuration

See [Common Configuration](#common-configuration) section above for the common configuration elements for all implementations.

##### Security Configuration 

| Option     | Default Value | Description                                                  |
| ---------- | ------------- | ------------------------------------------------------------ |
| AuthMode   | `none`        | Mode of authentication to use. Values are `none`, `usernamepassword`, `clientcert`, or `cacert`. The MQTT Broker is currently not secured in secure mode. |
| SecretName | blank         | Secret name used to look up credentials in the service's SecretStore |

##### Additional Configuration

| Option    | Default Value                                     | Description                                                  |
| -------------- | ------------------------------------------------------------ | -------------- |
| ClientId       | service key | Unique name of the client connecting to the MQTT broker      |
| Qos            | `0` | Quality of Service level <br />0: At most once delivery<br />1: At least once delivery<br />2: Exactly once delivery<br />See the [MQTT QOS Spec](http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718099) for more details |
| KeepAlive     | `10`        | Maximum time interval in seconds that is permitted to elapse between the point at which the client finishes transmitting one control packet and the point it starts sending the next. If exceeded, the broker will close the client connection |
| Retained       | `false` | If true, Server MUST store the Application Message and its QoS, so that it can be delivered to future subscribers whose subscriptions match its topic name. See [Retained Messages](https://www.hivemq.com/blog/mqtt-essentials-part-8-retained-messages) for more details. |
| AutoReconnect  | `true` | If true, automatically attempts to reconnect to the broker when connection is lost |
| ConnectTimeout | `30` | Timeout in seconds for the connection to the broker to be successful |
| CleanSession   | `false` | if true, Server MUST discard any previous Session and start a new one. This Session lasts as long as the Network Connection |

### NATS

NATS is a high performance messaging system that offers some interesting options for local deployments.  It uses a lightweight text-based protocol notably similar to http.  This protocol includes full header support that can allow conveyance of the EdgeX `MessageEnvelope` across service boundaries without the need for double-encoding if all services in the deployment are using NATS.  Currently services must be specially built with the `include_nats_messaging` tag to enable this option.

#### NATS Core

An ordinary NATS server uses interest, or existence of a client subscription, as the basis for subject availability on the server.  This makes Publish a fire and forget operation much like Redis, and gives the system an `at most once` quality of service.

#### NATS JetStream

The JetStream persistence layer binds NATS subjects to persistent streams which enables the server to collect messages for subjects that have no registered interest, and allows support for `at least once` quality of service.  Notably, services running in `core-nats` mode can still subscribe and publish to jetstream-enabled subjects without the additional overhead associated with publish acknowledgement.

#### Configuration

See [Common Configuration](#common-configuration) section above for the common configuration elements for all implementations.

##### Security Configuration 

| Option          | Default Value | Description                                                                                                                                                     |
|-----------------|---------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AuthMode        | `none`        | Mode of authentication to use. Values are `none`, `usernamepassword`, `clientcert`, or `cacert`. The NATS Server is currently not secured in secure mode.       |
| SecretName      | blank         | Secret name used to look up credentials in the service's SecretStore                                                                                            |
| NKeySeedFile    | blank         | Path to a seed file to use for authentication.  See the [NATS documentation](https://docs.nats.io/using-nats/developer/connecting/nkey) for more detail         |
| CredentialsFile | blank         | Path to a credentials file to use for authentication.  See the [NATS documentation](https://docs.nats.io/using-nats/developer/connecting/creds) for more detail |

##### Additional Configuration

| Option                  | Default Value | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
|-------------------------|---------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ClientId                | service key   | Unique name of the client connecting to the NATS Server                                                                                                                                                                                                                                                                                                                                                                                                            |
| Format                  | `nats`        | Format of the actual message published. Valid values are:<br />- **nats** : Metadata from the `MessageEnvlope` are put into the NATS header and the payload from the `MessageEnvlope` is published as is. **Preferred format when all services are using NATS**<br />- **json** : JSON encodes the `MessageEnvelope` and publish it as the message. Use this format for compatibility when other services using MQTT 3.1 and running the NATS Server in MQTT mode. |
| ConnectTimeout          | `30`          | Timeout in seconds for the connection to the broker to be successful                                                                                                                                                                                                                                                                                                                                                                                               |
| RetryOnFailedConnect    | `false`       | Retry on connection failure - expects a string representation of a boolean                                                                                                                                                                                                                                                                                                                                                                                         |
| QueueGroup              | blank         | Specifies a queue group to distribute messages from a stream to a pool of worker services                                                                                                                                                                                                                                                                                                                                                                          |
| Durable                 | blank         | Specifies a durable consumer should be used with the given name.  Note that if a durable consumer with the specified name does not exist it will be considered ephemeral and deleted by the client on drain / unsubscribe (**JetStream only**)                                                                                                                                                                                                                     |
| Subject                 | blank         | Specifies the subject for subscribing stream if a Durable is not specified - will also be formatted into a stream name to be used on subscription.  This subject is used for auto-provisioning the stream if needed as well and should be configured with the 'root' topic common to all subscriptions (eg `edgex/#`) to ensure that all topics on the bus are covered.   (**JetStream only**)                                                                     |
| AutoProvision           | `false`       | Automatically provision NATS streams. (**JetStream only**)                                                                                                                                                                                                                                                                                                                                                                                                         |
| Deliver                 | `new`         | Specifies delivery mode for subscriptions - options are "new", "all", "last" or "lastpersubject".  See the [NATS documentation](https://docs.nats.io/nats-concepts/jetstream/consumers#deliverpolicy-optstartseq-optstarttime) for more detail (**JetStream only**)                                                                                                                                                                                                |
| DefaultPubRetryAttempts | `2`           | Number of times to attempt to retry on failed publish (**JetStream only**)                                                                                                                                                                                                                                                                                                                                                                                         |

#### Resource Provisioning with nats-box

While the SDK will attempt to auto-provision streams needed if configured to do so, if you need specific features or policies enabled it is generally best to provision your own.  A [nats-box docker image](https://hub.docker.com/r/natsio/nats-box) is available preloaded with various utilities to make this easier.

For information on stream provisioning using the nats cli see [here](https://docs.nats.io/running-a-nats-service/configuration/resource_management/configuration_mgmt/nats-admin-cli).

For nkey generation a utility called [nk](https://github.com/nats-io/nkeys/tree/master/nk) is provided with nats-box.  For generating nkey seed files see [here](https://docs.nats.io/running-a-nats-service/configuration/securing_nats/auth_intro/nkey_auth).

For credential management a utility called [nsc](https://nats-io.github.io/nsc/) is provided with nats-box.  For using credentials files see documentation on [resolvers](https://docs.nats.io/running-a-nats-service/configuration/securing_nats/auth_intro/jwt/resolver) and the companion [memory resolver tutorial](https://docs.nats.io/running-a-nats-service/configuration/securing_nats/auth_intro/jwt/mem_resolver).

#### NATS MQTT Mode

A JetStream enabled server can support MQTT connections on the same set of underlying subjects.  This can be especially useful if you are using prebuilt EdgeX services like [device-onvif-camera](https://github.com/edgexfoundry/device-onvif-camera) but want to transition your system towards using NATS.  Note that `format=json` must be used so that the NATS messagebus client can read the double-encoded envelopes sent by MQTT clients.  For more information see [NATS MQTT Documentation](https://docs.nats.io/running-a-nats-service/configuration/mqtt).

## Multi-level topics and wildcards

The EdgeX MessageBus uses multi-level topics and wildcards to allow filtering of data via subscriptions and has standardized on a MQTT like scheme. See [MQTT multi-level topics and wildcards](https://www.hivemq.com/blog/mqtt-essentials-part-5-mqtt-topics-best-practices) for more information.

The Redis implementation converts the Redis Pub/Sub multi-level topic scheme to match that of MQTT. In Redis Pub/Sub the "**.**" is used as a level separator, "\*" followed by a level separator is used as the single level wildcard and "*" at the end is used as the multiple level wildcard. These are converted to "/" and "+" and "#" respectively, which are used by MQTT.


The NATS implementations convert the NATS multi-level topic scheme to match that of MQTT. In NATS "**.**" is used as a level separator, "\*" is used as the single level wildcard and ">" is used for the multi-level wild card. These are converted to "/", "+" and "#" respectively, which are compliant with the MQTT scheme.

!!! example - "Example Multi-level topics and wildcards for EdgeX MessageBus"
    - **edgex/events/#**

        All events coming from any device service or core data for any device profile, device or source
      
    - **edgex/events/device/#**
    
        All events coming from any device service for any device profile, device or source

    - **edgex/events/+/device-onvif-camera/#**
    
        Events coming from only device service "device-onvif-camera" for any device profile, device and source
      
    - **edgex/events/+/+/+/camera-001/#**
    
        Events coming from any device service or core data for any device profile, but only for the device "camera-001" and for any source
      
    - **edgex/events/device/+/onvif/+/status**
    
        Events coming from any device service for only the device profile "onvif", and any device and only for the source "status"


## Deployment

### Redis Pub/Sub (default)

All EdgeX services are capable of using the Redis Pub/Sub without any changes to configuration. The released compose files and snaps use Redis Pub/Sub.

### MQTT 3.1

All EdgeX services are capable of using MQTT 3.1 by simply making changes to each service's configuration. 

!!! note
    As mentioned above, the MQTT 3.1 implementation requires the addition of a MQTT Broker service to be running.

#### Configuration Changes

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 `MessageQueue` configuration has been renamed to MessageBus and is now in common configuration.

The MessageBus configuration is in common configuration where the following changes only need to be made once and apply to all services. See the **MessageBus** tab in [Common Configuration](../configuration/CommonConfiguration/#configuration-properties) for more details.

!!! example - "Example MQTT Configurations changes for all services"
    The following `MessageBus` configuration settings must be changed in common configuration for all EdgeX Services to use MQTT 3.1
    ```yaml
    MessageBus:
      Type: "mqtt"
      Protocol: "tcp" 
      Host: "localhost" # in docker this must be overriden to be the docker host name of the MQTT Broker
      Port: 1883
      AuthMode: "none"  # set to "usernamepassword" when running in secure mode
      SecreName: "message-bus"
      ...
    ```

!!! note
    The optional settings that apply to MQTT are already in the common configuration, so are not included above.

#### Docker

The EdgeX Compose Builder utility provides an option to easily generate a compose file with all the selected services re-configured for MQTT 3.1 using environment overrides. This is accomplished by using the `mqtt-bus` option. See [Compose Builder README](https://github.com/edgexfoundry/edgex-compose/tree/{{latest_release_name}}/compose-builder) for details on all available options.

!!! example - "Example Secure mode compose generation for MQTT 3.1"
    ```
    make gen ds-virtual ds-rest mqtt-bus
    ```

!!! example - "Non-secure mode compose generation for MQTT 3.1"
    ```
    make gen no-secty ds-virtual ds-rest mqtt-bus
    ```

!!! note
    The `run` command can be used to generate and run the compose file in one command, but any changes made to the generated compose file will be overridden the next time `run` is used. An alternative is to use the `up` command, which runs the latest generated compose file with any modifications that may have been made.

#### Snaps

For Snap deployment, each services' configuration has to modified manually or via environment overrides after install. For more details see the [Configuration](../../../getting-started/Ch-GettingStartedSnapUsers/#configuration) section in the Snaps getting started guide.

### NATS

The EdgeX Go based services are not capable of using the NATS implementation without being rebuild using the `include_nats_messaging` build tag. Any EdgeX Core/Support/Go Device/Application Service targeted to use NATS in a deployment must have the Makefile modified to add this build flag. The service can then be rebuild for native and/or Docker.

!!! example - "Core Data make target modified to include NATS"
    ````makefile
    cmd/core-data/core-data:
    	$(GOCGO) build -tags "include_nats_messaging $(NON_DELAYED_START_GO_BUILD_TAG_FOR_CORE)" $(CGOFLAGS) -o $@ ./cmd/core-data
    ````

!!! note
    The C Device SDK does not currently have a NATS implementation, so C Devices can not be used with the NATS based EdgeX MessageBus.

#### Configuration Changes

!!! edgey - "Edgex 3.0"
    For EdgeX 3.0 `MessageQueue` configuration has been renamed to MessageBus and is now in common configuration.

The MessageBus configuration is in common configuration where the following changes only need to be made once and apply to all services. See the **MessageBus** tab in [Common Configuration](../configuration/CommonConfiguration/#configuration-properties) for more details.

!!! example - "Example NATS Configurations changes for all services"
    The following `MessageBus` configuration settings must be changed in common configuration for all EdgeX Services to use NATS Jetstream
    ```yaml
    MessageBus:
      Type:  "nats-jetstream"
      Protocol:  "tcp" 
      Host:  "localhost" # in docker this must be overriden to be the docker host name of the NATS server
      Port:  4222
      AuthMode:  "none"  # Currently in secure mode the NATS server is not secured
    ```
!!! note
    The optional setting that apply to NATS are already in the common configuration, so are not included above.

#### Docker

The EdgeX Compose Builder utility provides an option to easily generate a compose file with all the selected services re-configured for NATS using environment overrides. This is accomplished by using the `nats-bus` option. This option configures the services to use the NATS Jetstream implementation. See [Compose Builder README](https://github.com/edgexfoundry/edgex-compose/tree/{{latest_release_name}}/compose-builder) for details on all available options. If NATS Core is preferred, simply do a search and replace of `nats-jeststream` with `nats-core` in the generated compose file.

!!! example - "Example Secure mode compose generation for NATS"

    ```
    make gen ds-virtual ds-rest nats-bus
    ```

!!! example - "Non-secure mode compose generation for NATS"

    ```
    make gen no-secty ds-virtual ds-rest nats-bus
    ```

#### Snaps

The published Snaps are built without NATS included, so the use of NATS in those Snaps is not possible. One could modify the Makefiles as described above and then build and install local snap packages. In this case it would be easier to modify each service's configuration as describe above so that the locally built and installed snaps are already configured for NATS.
