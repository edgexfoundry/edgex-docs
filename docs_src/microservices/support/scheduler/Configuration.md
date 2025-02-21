--- 
title: Support Scheduler - Configuration
---

# Support Scheduler - Configuration

Please refer to the general [Common Configuration documentation](../../configuration/CommonConfiguration.md) for configuration settings common to all services.
Below are only the additional settings and sections that are specific to Support Scheduler.

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 the `MessageQueue` configuration has been moved to `MessageBus` in [Common Configuration](../../configuration/CommonConfiguration.md#common-configuration-properties)

=== "Writable"
    |Property|Default Value|Description|
    |---|---|---|
    ||Writable properties can be set and will dynamically take effect without service restart|
    |LogLevel|INFO|log entry [severity level](https://en.wikipedia.org/wiki/Syslog#Severity_level).  Log entries not of the default level or higher are ignored. |
=== "Writable.InsecureSecrets"
    |Property|Default Value|Description|
    |---|---|---|
    |.DB|---|Secrets for connecting to postgres when running in non-secure mode |
=== "Writable.Telemetry"
    |Property|Default Value|Description|
    |---|---|---|
    |||See `Writable.Telemetry` at [Common Configuration](../../configuration/CommonConfiguration.md#common-configuration-properties) for the Telemetry configuration common to all services |
    |Metrics| `TBD` |Service metrics that Support Scheduler collects. Boolean value indicates if reporting of the metric is enabled.|
    |Tags|`<empty>`|List of arbitrary service level tags to included with every metric that is reported. i.e. `Gateway="my-iot-gateway"` |
=== "Service"
    |Property|Default Value|Description|
    |---|---|---|
    ||| Unique settings for Support Scheduler. The common settings can be found at [Common Configuration](../../configuration/CommonConfiguration.md#common-configuration-properties)
    |Port|59863|Micro service port number|
    |StartupMsg |This is the Support Scheduler Microservice|Message logged when service completes bootstrap start-up|
=== "Clients.core-command"
    |Property|Default Value|Description|
    |---|---|---|
    |Protocol|http|The protocol to use when building a URI to the service endpoint|
    |Host|localhost|The host name or IP address where the service is hosted|
    |Port|59882|The port exposed by the target service|
=== "MessageBus.Optional"
    |Property|Default Value|Description|
    |---|---|---|
    ||| Unique settings for Support Scheduler. The common settings can be found at [Common Configuration](../../configuration/CommonConfiguration.md#common-configuration-properties)
    |ClientId|"support-cron-scheduler|Id used when connecting to MQTT or NATS base MessageBus|
=== "Database"
    |Property|Default Value|Description|
    |---|---|---|
    |||Unique settings for Support Scheduler. The common settings can be found at [Common Configuration](../../configuration/CommonConfiguration.md#common-configuration-properties)
    |Host|localhost|The host name or IP address where the database is hosted|
    |Port|5432|The port exposed by the database|
    |Timeout|5s|DB connection timeout|
    |Type|postgres|Indicates the type of database to use, only postgres is supported for this release|

    !!! edgey "EdgeX 4.0"
        For EdgeX 4.0 the Support Scheduler service only supports `postgres` as persistence layer.
=== "Retention"
    |Property|Default Value|Description|    
    |---|---|---|
    |Enabled|true|Enable or disable data retention.|
    |Interval|24h|Purging interval defines when the database should be rid of schedule action records above the MaxCap.|
    |MaxCap|10000|The maximum capacity defines where the high watermark of schedule action records should be detected for purging the amount of the record to the minimum capacity.|
    |MinCap|8000|The minimum capacity defines where the total count of schedule action records should be returned to during purging.|

## V3 Configuration Migration Guide
No configuration updated

See [Common Configuration Reference](../../configuration/V3MigrationCommonConfig.md) for complete details on common configuration changes.
