# EdgeX MessageBus

## Introduction

EdgeX has an internal message bus referred to as the **EdgeX MessageBus** , which is used for internal communications between EdgeX services. An EdgeX Service is any Core/Support/Application/Device Service from EdgeX or any custom Application or Device Service built with the EdgeX SDKs. 

The following diagram shows how each of the EdgeX Service use the EdgeX MessageBus.

![[Insert Image of EdgeX MessageBus]](./messagebus diagram.jpg)

The EdgeX MessageBus is meant for internal EdgeX service to service communications. It is not meant as an entry point for external services to communicate with the internal EdgeX services. The eKuiper Rules Engine is an exception to this as it is tightly integrated with EdgeX.

The EdgeX services intended as external entry points are:

- **REST API on all the EdgeX services** - Accessed directly in non-secure mode or via the [API Gateway](../../../security/Ch-APIGateway) when running in secure mode

- **App Service using External MQTT Trigger** - An App Service configured to use the [External MQTT Trigger](../application/details/Triggers.md#external-mqtt-trigger) will accept data from external services on an "external" MQTT connection
  
- **App Service using HTTP Trigger** - An App Service configured to use the [HTTP Trigger](../application/details/Triggers.md#http-trigger) will accept data from external services on an "external" REST connection. Accessed in the same manner as other EdgeX REST APIs.

- **App Service using Custom Trigger** - An App Service configured to use a [Custom Trigger](../application/details/Triggers.md#custom-triggers) can accept data from external services or over additional protocols with few limitations. See [Custom Trigger Example](https://github.com/edgexfoundry/edgex-examples/tree/{{edgexversion}}/application-services/custom/custom-trigger) for an example.

- **Core Command External MQTT Connection** - Core Command now receives command requests and publishes responses via an external MQTT connection that is separate from the EdgeX MessageBus. The requests are forwarded to the EdgeX MessageBus and the corresponding responses are forwarded back to the external MQTT connection. 

Originally, the EdgeX MessageBus was only used to send *Event/Readings* from Core Data to the Application Services layer. In recent releases, more services use the EdgeX MessageBus rather than REST for inter service communication.  

- Device Services publish *Event/Readings* directly to the EdgeX MessageBus rather than sending them via REST to Core Data. 
- [Service Metrics](../#service-metrics) are published to the EdgeX MessageBus
- [System Events](../core/metadata/details/DeviceSystemEvents.md) are published to the EdgeX MessageBus. 
- [Command Request/Reponses](../../../design/adr/0023-North-South-Messaging) are now published to the EdgeX MessageBus by Core Command and Devices Services.  
- Device validation requests from Core Metadata to Device Services via the EdgeX MessageBus.

## Message Envelope

All messages published to the EdgeX MessageBus are wrapped in a `MessageEnvelope`. This envelope contains metadata describing the message payload, such as the payload Content Type (JSON or CBOR), Correlation Id, etc. 

!!! note
    Unless noted below, the `MessageEnvelope` is  JSON encoded when publishing it to the EdgeX MessageBus. This does result in the `MessageEnvelope`'s payload being double encoded.

## Implementations

The EdgeX MessageBus is defined by the message bus abstraction implemented in [go-mod-messaging](https://github.com/edgexfoundry/go-mod-messaging). This module defines an abstract client API which currently has four implementations of the API for the different underlying message bus protocols. 

### Common MessageBus Configuration

Each service that uses the EdgeX MessageBus has a configuration section which defines the implementation to use, the connection method, and the underlying protocol client. This section is the `MessageBus:` section in the service common configuration for all EdgeX services. See the **MessageBus** tab in [Common Configuration](../../configuration/CommonConfiguration/#common-configuration-properties) for more details. 

The common MessageBus configuration elements for each implementation are:

- Type - Specifies which of the following implementations to use. 
    - **MQTT 3.1**(**default**) - `Type=mqtt`
    - **NATS Core** - `Type=nats-core` 
    - **NATS JetStream** - `Type=nats-jetstream` 
- Host - Specifies the name or IP for the message broker 
- Port - Specifies the port number for the message broker 
- Protocol - Specifies portocol used by the message broker
    - `tcp` for **MQTT 3.1 (default)**
    - `tcp` for **NATS Core**
    - `tcp` for **NATS JetStream**

!!! note
    In general all EdgeX Services running in a deployment must be configured to use the same EdgeX MessageBus implementation. By default all services that use the EdgeX MessageBus are configured to use the MQTT implementation. NATS does support a compatibility mode with MQTT. See the [NATS MQTT Mode](#nats-mqtt-mode) section below for details.

### MQTT 3.1 (default)

Robust message bus protocol, which has additional configuration options for robustness and requires an additional MQTT Broker to be running. See [MQTT Spec](http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html) for more details on this protocol.

#### Configuration

See [Common Configuration](#common-messagebus-configuration) section above for the common configuration elements for all implementations.

##### Security Configuration 

| Option     | Default Value | Description                                                  |
| ---------- | ------------- | ------------------------------------------------------------ |
| AuthMode   | `none`        | Mode of authentication to use. Values are `none`, `usernamepassword`, `clientcert`, or `cacert`. In secure mode the MQTT Broker uses `usernamepassword` |
| SecretName | blank         | Secret name used to look up credentials in the service's SecretStore |

##### Additional Configuration 

Except where noted default values exist in the service common configuration.

| Option    | Default Value                                     | Description                                                  |
| -------------- | ------------------------------------------------------------ | -------------- |
| ClientId       | service key | Unique name of the client connecting to the MQTT broker (**Set in each service's private configuration**) |
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

The JetStream persistence layer binds NATS subjects to persistent streams which enables the server to collect messages for subjects that have no registered interest, and allows support for `at least once` quality of service.  JetStream also supports [exactly once QoS](https://docs.nats.io/using-nats/developer/develop_jetstream/model_deep_dive#exactly-once-semantics).  This can be enabled using the `ExactlyOnce` option on both the publish and subscribe sides of a message bus connection.  The header used for deduplication will be a combination of the service key and message's correlation ID.  Notably, services running in `core-nats` mode can still subscribe and publish to jetstream-enabled subjects without the additional overhead associated with publish acknowledgement.

#### Configuration

See [Common Configuration](#common-messagebus-configuration) section above for the common configuration elements for all implementations.

##### Security Configuration 

| Option          | Default Value | Description                                                                                                                                                     |
|-----------------|---------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AuthMode        | `none`        | Mode of authentication to use. Values are `none`, `usernamepassword`, `clientcert`, or `cacert`. The NATS Server is currently not secured in secure mode.       |
| SecretName      | blank         | Secret name used to look up credentials in the service's SecretStore                                                                                            |
| NKeySeedFile    | blank         | Path to a seed file to use for authentication.  See the [NATS documentation](https://docs.nats.io/using-nats/developer/connecting/nkey) for more detail         |
| CredentialsFile | blank         | Path to a credentials file to use for authentication.  See the [NATS documentation](https://docs.nats.io/using-nats/developer/connecting/creds) for more detail |

##### Additional Configuration

Except where noted default values exist in the service common configuration.

| Option                  | Default Value | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
|-------------------------|---------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ClientId                | service key   | Unique name of the client connecting to the NATS Server (**Set in each service's private configuration**)                                                                                                                                                                                                                                                                                                                                                          |
| Format                  | `nats`        | Format of the actual message published. Valid values are:<br />- **nats** : Metadata from the `MessageEnvlope` are put into the NATS header and the payload from the `MessageEnvlope` is published as is. **Preferred format when all services are using NATS**<br />- **json** : JSON encodes the `MessageEnvelope` and publish it as the message. Use this format for compatibility when other services using MQTT 3.1 and running the NATS Server in MQTT mode. |
| ConnectTimeout          | `30`          | Timeout in seconds for the connection to the broker to be successful                                                                                                                                                                                                                                                                                                                                                                                               |
| RetryOnFailedConnect    | `false`       | Retry on connection failure - expects a string representation of a boolean                                                                                                                                                                                                                                                                                                                                                                                         |
| QueueGroup              | blank         | Specifies a queue group to distribute messages from a stream to a pool of worker services                                                                                                                                                                                                                                                                                                                                                                          |
| Durable                 | blank         | Specifies a durable consumer should be used with the given name.  Note that if a durable consumer with the specified name does not exist it will be considered ephemeral and deleted by the client on drain / unsubscribe (**JetStream only**)                                                                                                                                                                                                                     |
| Subject                 | blank         | Specifies the subject for subscribing stream if a Durable is not specified - will also be formatted into a stream name to be used on subscription.  This subject is used for auto-provisioning the stream if needed as well and should be configured with the 'root' topic common to all subscriptions (eg `edgex/#`) to ensure that all topics on the bus are covered.   (**JetStream only**)                                                                     |
| AutoProvision           | `false`       | Automatically provision NATS streams. (**JetStream only**)                                                                                                                                                                                                                                                                                                                                                                                                         |
| Deliver                 | `new`         | Specifies delivery mode for subscriptions - options are "new", "all", "last" or "lastpersubject".  See the [NATS documentation](https://docs.nats.io/nats-concepts/jetstream/consumers#deliverpolicy-optstartseq-optstarttime) for more detail (**JetStream only**)                                                                                                                                                                                                |
| DefaultPubRetryAttempts | `2`           | Number of times to attempt to retry on failed publish (**JetStream only**)                                                                                                                                                                                                                                                                                                                                                                                         |
| ExactlyOnce             | `false`       | Enables publish and subscribe side behavior for exactly once QoS (**JetStream only**)                                                                                                                                                                                                                                                                                                                                                                              |

#### Resource Provisioning with nats-box

While the SDK will attempt to auto-provision streams needed if configured to do so, if you need specific features or policies enabled it is generally best to provision your own.  A [nats-box docker image](https://hub.docker.com/r/natsio/nats-box) is available preloaded with various utilities to make this easier.

For information on stream provisioning using the nats cli see [here](https://docs.nats.io/running-a-nats-service/configuration/resource_management/configuration_mgmt/nats-admin-cli).

For nkey generation a utility called [nk](https://github.com/nats-io/nkeys/tree/master/nk) is provided with nats-box.  For generating nkey seed files see [here](https://docs.nats.io/running-a-nats-service/configuration/securing_nats/auth_intro/nkey_auth).

For credential management a utility called [nsc](https://nats-io.github.io/nsc/) is provided with nats-box.  For using credentials files see documentation on [resolvers](https://docs.nats.io/running-a-nats-service/configuration/securing_nats/auth_intro/jwt/resolver) and the companion [memory resolver tutorial](https://docs.nats.io/running-a-nats-service/configuration/securing_nats/auth_intro/jwt/mem_resolver).

#### NATS MQTT Mode

A JetStream enabled server can support MQTT connections on the same set of underlying subjects.  This can be especially useful if you are using prebuilt EdgeX services like [device-onvif-camera](https://github.com/edgexfoundry/device-onvif-camera) but want to transition your system towards using NATS.  Note that `format=json` must be used so that the NATS messagebus client can read the double-encoded envelopes sent by MQTT clients.  For more information see [NATS MQTT Documentation](https://docs.nats.io/running-a-nats-service/configuration/mqtt).

## Multi-level topics and wildcards

The EdgeX MessageBus uses multi-level topics and wildcards to allow filtering of data via subscriptions and has standardized on a MQTT like scheme. See [MQTT multi-level topics and wildcards](https://www.hivemq.com/blog/mqtt-essentials-part-5-mqtt-topics-best-practices) for more information.


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

### MQTT 3.1 (default)

All EdgeX services are capable of using MQTT 3.1 by simply making changes to each service's configuration. 

!!! note
    As mentioned above, the MQTT 3.1 implementation requires the addition of a MQTT Broker service to be running.

#### Configuration Changes

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 `MessageQueue` configuration has been renamed to `MessageBus` and is now in common configuration.

The MessageBus configuration is in common configuration where the following changes only need to be made once and apply to all services. See the **MessageBus** tab in [Common Configuration](../../configuration/CommonConfiguration/#common-configuration-properties) for more details.

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

The EdgeX Compose Builder utility provides an option to easily generate a compose file with all the selected services re-configured for MQTT 3.1 using environment overrides. This is accomplished by using the `mqtt-bus` option. See [Compose Builder README](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder/README.md) for details on all available options.

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
    For EdgeX 3.0 `MessageQueue` configuration has been renamed to `MessageBus` and is now in common configuration.

The MessageBus configuration is in common configuration where the following changes only need to be made once and apply to all services. See the **MessageBus** tab in [Common Configuration](../../configuration/CommonConfiguration/#common-configuration-properties) for more details.

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

The EdgeX Compose Builder utility provides an option to easily generate a compose file with all the selected services re-configured for NATS using environment overrides. This is accomplished by using the `nats-bus` option. This option configures the services to use the NATS Jetstream implementation. See [Compose Builder README](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder/README.md) for details on all available options. If NATS Core is preferred, simply do a search and replace of `nats-jetstream` with `nats-core` in the generated compose file.

!!! example - "Example Secure mode compose generation for NATS"

    ```
    make gen ds-virtual ds-rest nats-bus
    ```

!!! example - "Non-secure mode compose generation for NATS"

    ```
    make gen no-secty ds-virtual ds-rest nats-bus
    ```

