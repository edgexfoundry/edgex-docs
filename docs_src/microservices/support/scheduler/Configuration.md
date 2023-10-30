--- 
title: Support Scheduler - Configuration
---

# Support Scheduler - Configuration

Please refer to the general [Common Configuration documentation](../../configuration/CommonConfiguration.md) for configuration settings common to all services.
Below are only the additional settings and sections that are specific to Support Scheduler.

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 the `MessageQueue` configuration has been moved to `MessageBus` in [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)

=== "Writable"
    |Property|Default Value|Description|
    |---|---|---|
    ||Writable properties can be set and will dynamically take effect without service restart|
    |LogLevel|INFO|log entry [severity level](https://en.wikipedia.org/wiki/Syslog#Severity_level).  Log entries not of the default level or higher are ignored. |
=== "Writable.Telemetry"
    |Property|Default Value|Description|
    |---|---|---|
    |||See `Writable.Telemetry` at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties) for the Telemetry configuration common to all services |
    |Metrics| `TBD` |Service metrics that Support Scheduler collects. Boolean value indicates if reporting of the metric is enabled.|
    |Tags|`<empty>`|List of arbitrary service level tags to included with every metric that is reported. i.e. `Gateway="my-iot-gateway"` |
=== "ScheduleIntervalTime"
    |Property|Default Value|Description|
    |---|---|---|
    |ScheduleIntervalTime|500|the time, in milliseconds, to trigger any applicable interval actions|
=== "Service"
    |Property|Default Value|Description|
    |---|---|---|
    ||| Unique settings for Support Scheduler. The common settings can be found at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)
    | Port | 59861|Micro service port number|
    |StartupMsg |This is the Support Scheduler Microservice|Message logged when service completes bootstrap start-up|
=== "Database"
    |Property|Default Value|Description|
    |---|---|---|
    ||| Unique settings for Support Scheduler. The common settings can be found at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)
    |Name|'scheduler'|Document store or database name|
=== "MessageBus.Optional"
    |Property|Default Value|Description|
    |---|---|---|
    ||| Unique settings for Support Notifications. The common settings can be found at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)
    |ClientId|"support-scheduler| Id used when connecting to MQTT or NATS base MessageBus |
=== "Intervals/Intervals.Midnight"
    |Property|Default Value|Description|
    |---|---|---|
    ||Default intervals for use with default interval actions|
    |Name|midnight|Name of the every day at midnight interval|
    |Start|20180101T000000|Indicates the start time for the midnight interval which is a midnight, Jan 1, 2018 which effectively sets the start time as of right now since this is in the past|
    |Interval|24h|defines a frequency of every 24 hours|
=== "IntervalActions.IntervalActions.ScrubAged"
    |Property|Default Value|Description|
    |---|---|---|
    ||Configuration of the core data clean old events operation which is to kick off every midnight|
    |Name|scrub-aged-events|name of the interval action|
    |Host|localhost|run the request on core data assumed to be on the localhost|
    |Port|59880|run the request against the default core data port|
    |Protocol|http|Make a RESTful request to core data|
    |Method|DELETE|Make a RESTful delete operation request to core data|
    |Path|/api/{{api_version}}/event/age/604800000000000|request core data's remove old events API with parameter of 7 days |
    |Interval|midnight|run the operation every midnight as specified by the configuration defined interval|

## V3 Configuration Migration Guide
- Removed `RequireMessageBus`
- A new field `AuthMethod` is added to `IntervalActions.ScrubAged`

See [Common Configuration Reference](../../../configuration/V3MigrationCommonConfig/) for complete details on common configuration changes.
