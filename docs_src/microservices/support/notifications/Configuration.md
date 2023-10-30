---
title: Support Notification - Configuration
---

# Support Notification - Configuration

## Configuration Properties

Please refer to the general [Common Configuration documentation](../../configuration/CommonConfiguration.md) for configuration settings common to all services.
Below are only the additional settings and sections that are specific to Support Notifications.

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 the `MessageQueue` configuration has been moved to `MessageBus` in [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)

=== "Writable"
    |Property|Default Value|Description|
    |---|---|---|
    |||Writable properties can be set and will dynamically take effect without service restart|
    |LogLevel|INFO|log entry [severity level](https://en.wikipedia.org/wiki/Syslog#Severity_level).  Log entries not of the default level or higher are ignored. |
    |ResendLimit|2|Sets the retry limit for attempts to send notifications. CRITICAL notifications are sent to the escalation subscriber when resend limit is exceeded.|
    |ResendInterval|'5s'|Sets the retry interval for attempts to send notifications.|
    |Writable.InsecureSecrets.SMTP.Secrets username|username@mail.example.com|The email to send alerts and notifications|
    |Writable.InsecureSecrets.SMTP.Secrets password||The email password|
=== "Writable.Telemetry"
    |Property|Default Value|Description|
    |---|---|---|
    |||See `Writable.Telemetry` at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties) for the Telemetry configuration common to all services |
    |Metrics| `TBD` |Service metrics that Support Notification collects. Boolean value indicates if reporting of the metric is enabled.|
    |Tags|`<empty>`|List of arbitrary service level tags to included with every metric that is reported. i.e. `Gateway="my-iot-gateway"` |
=== "Service"
    |Property|Default Value|Description|
    |---|---|---|
    ||| Unique settings for Support Notifications. The common settings can be found at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)
    | Port | 59860|Micro service port number|
    |StartupMsg |This is the Support Notifications Microservice|Message logged when service completes bootstrap start-up|
=== "Database"
    |Property|Default Value|Description|
    |---|---|---|
    ||| Unique settings for Support Notifications. The common settings can be found at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)
    |Name|'notifications'|Document store or database name|
=== "MessageBus.Optional"
    |Property|Default Value|Description|
    |---|---|---|
    ||| Unique settings for Support Notifications. The common settings can be found at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)
    |ClientId|"support-notifications| Id used when connecting to MQTT or NATS base MessageBus |
=== "Smtp"
    |Property|Default Value|Description|
    |---|---|---|
    |||Config to connect to applicable SMTP (email) service. All the properties with prefix "smtp" are for mail server configuration. Configure the mail server appropriately to send alerts and notifications. The correct values depend on which mail server is used.|
    |Smtp Host|smtp.gmail.com |SMTP service host name|
    |Smtp Port|587 | SMTP service port number|
    |Smtp EnableSelfSignedCert | false | Indicates whether a self-signed cert can be used for secure connectivity. |
    |Smtp SecretPath| smtp | Specify the secret path to store the credential(username and password) for connecting the SMTP server via the /secret API, or set Writable SMTP username and password for insecure secrets|
    |Smtp Sender|jdoe@gmail.com |SMTP service sender/username|
    |Smtp Subject|EdgeX Notification|SMTP notification message subject|
=== "Retention"
    |Property|Default Value|Description|    
    |---|---|---|
    | Enabled|false|Enable or disable notification retention.|
    | Interval|30m|Purging interval defines when the database should be rid of notifications above the MaxCap.|
    | MaxCap|5000|The maximum capacity defines where the high watermark of notifications should be detected for purging the amount of the notification to the minimum capacity.|
    | MinCap|4000|The minimum capacity defines where the total count of notifications should be returned to during purging.|

### V3 Configuration Migration Guide
No configuration updated

See [Common Configuration Reference](../../../configuration/V3MigrationCommonConfig/) for complete details on common configuration changes.

### Writable

The `Writable.InsecureSecrets.SMTP` section has been added.

!!! example "Example Writable.InsecureSecrets.SMTP section"
    ```yaml
        Writable:
          InsecureSecrets:
            SMTP:
              SecretName: "smtp"
              SecretData:
                username: "username@mail.example.com"
                password: ""
    ```
