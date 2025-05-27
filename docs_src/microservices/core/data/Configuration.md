---
title: Core Data - Configuration
---

# Core Data - Configuration

Please refer to the general [Common Configuration documentation](../../configuration/CommonConfiguration.md) for configuration settings common to all services.
Below are only the additional settings and sections that are specific to Core Data.

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 the `MessageQueue` configuration has been moved to `MessageBus` in [Common Configuration](../../configuration/CommonConfiguration.md#common-configuration-properties)

=== "Writable"
|Property|Default Value|Description|
|---|---|---|
||Writable properties can be set and will dynamically take effect without service restart|
|LogLevel|INFO|log entry [severity level](https://en.wikipedia.org/wiki/Syslog#Severity_level).  Log entries not of the default level or higher are ignored. |
|PersistData|true|When true, Core Data persists all sensor data sent to it in its associated database|
|EventPurge|false|When true, Core Data removes the related events and readings once received the device deletion system event|
=== "Writable.Telemetry"
|Property|Default Value|Description|
|---|---|---|
|||See `Writable.Telemetry` at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties) for the Telemetry configuration common to all services |
| Metrics| |Service metrics that Core Data collects. Boolean value indicates if reporting of the metric is enabled.|
|Metrics.EventsPersisted |  false| Enable/Disable reporting of number of events persisted.|
|Metrics.ReadingsPersisted | false|Enable/Disable reporting of number of readings persisted.|
|Tags|`<empty>`|List of arbitrary Core Data service level tags to be included with every metric that is reported.  |
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
=== "Retention"
|Property|Default Value|Description|    
|---|---|---|
| Interval|10m|Purging interval defines when the database should be rid of events above the MaxCap.|
| DefaultMaxCap|-1|The default maximum capacity defines where the high watermark of events should be detected for purging the amount of the event to the minimum capacity. The default value is `-1` to disable this feature.|
| DefaultMinCap|1|The default minimum capacity defines where the total count of event should be kept during purging. The default value is `1`. Be careful to use `minCap`, since the database uses offset to count the rows, the value becomes larger, and the database needs more time to count the rows.|
| DefaultDuration|168h|The default duration to keep the event, the default value is `"168h"`.|

## V3 Configuration Migration Guide
No configuration updated

See [Common Configuration Reference](../../../configuration/V3MigrationCommonConfig/) for complete details on common configuration changes.