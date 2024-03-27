---
title: Core Command - Configuration
---

# Core Command - Configuration

Please refer to the general [Common Configuration documentation](../../configuration/CommonConfiguration.md) for configuration settings common to all services.
Below are only the additional settings and sections that are specific to Core Command.

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 the `MessageQueue.Internal` configuration has been moved to `MessageBus` in [Common Configuration](../../configuration/CommonConfiguration.md#common-configuration-properties) and `MessageQueue.External` has been moved to `ExternalMQTT` below

=== "Writable"
|Property|Default Value|Description|
|---|---|---|
|||entries in the Writable section of the configuration can be changed on the fly while the service is running if the service is running with the `-cp/--configProvider` flag|
|LogLevel|INFO|log entry [severity level](https://en.wikipedia.org/wiki/Syslog#Severity_level).  Log entries not of the default level or higher are ignored. |
=== "Writable.InsecureSecrets"
|Property|Default Value|Description|
|---|---|---|
|.mqtt|---|Secrets for when connecting to secure External MQTT when running in non-secure mode |
=== "Writable.Telemetry"
|Property|Default Value|Description|
|---|---|---|
|||See `Writable.Telemetry` at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties) for the Telemetry configuration common to all services |
|Metrics| `<TBD>` |Service metrics that Core Command collects. Boolean value indicates if reporting of the metric is enabled.|
|Tags|`<empty>`|List of arbitrary Core Metadata service level tags to included with every metric that is reported. |
=== "Service"
|Property|Default Value|Description|
|---|---|---|
||| Unique settings for Core Command. The common settings can be found at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)
| Port | 59882|Micro service port number|
|StartupMsg |This is the EdgeX Core Command Microservice|Message logged when service completes bootstrap start-up|
=== "Clients.core-metadata"
|Property|Default Value|Description|
|---|---|---|
|Protocol|http| The protocol to use when building a URI to the service endpoint|
|Host|localhost| The host name or IP address where the service is hosted |
|Port|59881| The port exposed by the target service|
=== "MessageBus.Optional"
|Property|Default Value|Description|
|---|---|---|
||| Unique settings for Core Command. The common settings can be found at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)
|ClientId|"core-command|Id used when connecting to MQTT or NATS base MessageBus |
=== "ExternalMqtt"
|Property|Default Value|Description|
|---|---|---|
| Enabled | false | Indicates whether to connect to external MQTT broker for the Commands via messaging |
| Url | `tcp://localhost:1883` | Fully qualified URL to connect to the MQTT broker |
| ClientId | `core-command` | ClientId to connect to the broker with |
| ConnectTimeout | 5s | Time duration indicating how long to wait before timing out                                                        broker connection, i.e "30s" |
| AutoReconnect | true | Indicates whether or not to retry connection if disconnected |
| KeepAlive | 10 | Seconds between client ping when no active data flowing to avoid client being disconnected. Must be greater then 2 |
| QOS | 0 | Quality of Service 0 (At most once), 1 (At least once) or 2 (Exactly once) |
| Retain | true | Retain setting for MQTT Connection                           |
| SkipCertVerify | false | Indicates if the certificate verification should be skipped  |
| SecretName | `mqtt` | Name of the path in secret provider to retrieve your secrets. Must be non-blank. |
| AuthMode | `none` | Indicates what to use when connecting to the broker. Must be one of "none", "cacert" , "usernamepassword", "clientcert". <br />If a CA Cert exists in the SecretPath then it will be used for all modes except "none". |
=== "ExternalMqtt.Topics"
|Property|Default Value|Description|
|---|---|---|
|||Key-value mappings allow for publication and subscription to the external message bus |
| CommandRequestTopic | `edgex/command/request/#` | For subscribing to 3rd party command requests |
| CommandResponseTopicPrefix | `edgex/command/response` | For publishing responses back to 3rd party systems. `/<device-name>/<command-name>/<method>` will be added to this publish topic prefix |
| QueryRequestTopic | `edgex/commandquery/request/#` | For subscribing to 3rd party command query requests |
| QueryResponseTopic | `edgex/commandquery/response` | For publishing command query responses back to 3rd party systems |

### V3 Configuration Migration Guide
- Removed `RequireMessageBus` 
- MessageQueue.External moved to ExternalMQTT

See [Common Configuration Reference](../../configuration/V3MigrationCommonConfig.md) for complete details on common configuration changes.