# Support Notifications

![image](EdgeX_SupportingServicesAlertsNotifications.png)

## Introduction

When another system or a person needs to know that something occurred in EdgeX, the
alerts and notifications microservice sends that notification.
Examples of alerts and notifications that other services could broadcast, include the provisioning of a new device, sensor data detected outside of certain parameters
(usually detected by a device service or rules engine) or system or service
malfunctions (usually detected by system management services).

### Terminology

**Notifications** are informative, whereas **Alerts** are typically of a
more important, critical, or urgent nature, possibly requiring immediate
action.

![image](EdgeX_SupportingServicesAlertsArchitecture.png)

This diagram shows the high-level architecture of the notifications service.
On the left side, the APIs are provided for other
microservices, on-box applications, and off-box applications to use.  The APIs could be in REST, AMQP, MQTT, or any standard application
protocols. 

This diagram is drawn by [diagrams.net](https://app.diagrams.net/) with the source file [EdgeX_SupportingServicesAlertsArchitecture.xml](EdgeX_SupportingServicesAlertsArchitecture.xml)

!!! Warning
    Currently in EdgeX Foundry, only the RESTful interface is provided.

On the right side, the notifications receiver could be a person or an
application system on Cloud or in a server room. By invoking the
Subscription RESTful interface to subscribe the specific types of
notifications, the receiver obtains the appropriate notifications
through defined receiving channels when events occur. The receiving
channels include SMS message, e-mail, REST callback, AMQP, MQTT, and so
on. 

!!! Warning
    Currently in EdgeX Foundry, e-mail and REST callback channels are provided.

When the notifications service receives notifications from any interface, 
the notifications are passed to the Notifications Handler internally. 
The Notifications Handler persists the received notifications first, 
and passes them to the Distribution Coordinator.

When the Distribution Coordinator receives a notification, it first
queries the Subscription database to get receivers who need this
notification and their receiving channel information. According to the
channel information, the Distribution Coordinator passes this
notification to the corresponding channel senders. Then, the channel
senders send out the notifications to the subscribed receivers.

### Workflow

#### Normal/Minor Notifications
When a client requests a notification to be sent with "NORMAL" or "MINOR" status, 
the notification is immediately sent to its receivers via the Distribution Coordinator, 
and the status is updated to "PROCESSED".

#### Critical Notifications
Notifications with "CRITICAL" status are also sent immediately.
When encountering any error during sending critical notification, 
an individual resend task is scheduled, and each transmission record persists.
After exceeding the configurable limit (resend limit), the service escalates the notification 
and create a new notification to notify particular receivers of the escalation subscription (name = "ESCALATION") of the failure.

!!! note 
    All notifications are processed immediately. The resend feature is only provided for critical notifications.
    The **resendLimit** and **resendInterval** properties can be defined in each subscription. 
    If the properties are not provided, use the default values in the configuration properties.

## Data Model
The latest developed data model will be updated in the [Swagger API document](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/support-notifications/2.0.0).

![image](EdgeX_SupportingServicesNotificationsModel.png)

This diagram is drawn by [diagrams.net](https://app.diagrams.net/) with the source file [EdgeX_SupportingServicesNotificationsModel.xml](EdgeX_SupportingServicesNotificationsModel.xml)

## Data Dictionary

=== "Subscription"
    |Property|Description|
    |---|---|
    ||The object used to describe the receiver and the recipient channels|
    |ID|Uniquely identifies a subscription, for example a UUID|  
    |Name|Uniquely identifies a subscription|
    |Receiver|The name of the party interested in the notification|
    |Description|Human readable description explaining the subscription intent|
    |Categories|Link the subscription to one or more categories of notification.|
    |Labels|An array of associated means to label or tag for categorization or identification|
    |Channels|An array of channel objects indicating the destination for the notification|
    |ResendLimit|The retry limit for attempts to send notifications|
    |ResendInterval|The interval in ISO 8691 format of resending the notification|
    |AdminState|An enumeration string indicating the subscription is locked or unlocked|
=== "Channel"
    |Property|Description|
    |---|---|
    ||The object used to describe the notification end point.  Channel supports transmissions and notifications with fields for delivery via email or REST|
    |Type|Object of ChannelType - indicates whether the channel facilitates email or REST|
    |MailAddress|EmailAddress object for an array of string email addresses|
    |RESTAddress|RESTAddress object for a REST API destination endpoint|
=== "Notification"
    |Property|Description|
    |---|---|
    ||The object used to describe the message and sender content of a notification.|
    |ID|Uniquely identifies a notification, for example a UUID|
    |Sender|A string indicating the notification message sender|
    |Category|A string categorizing the notification|
    |Severity|An enumeration string indicating the severity of the notification - as either normal or critical|
    |Content|The message sent to the receivers|
    |Description|Human readable description explaining the reason for the notification or alert|
    |Status|An enumeration string indicating the status of the notification as new, processed or escalated|
    |Labels|Array of associated means to label or tag a notification for better search and filtering|
    |ContentType|String indicating the type of content in the notification message|
=== "Transmission"
    |Property|Description|
    |---|---|
    ||The object used to group Notifications|
    |ID|Uniquely identifies a transmission, for example a UUID|
    |Created|A timestamp indicating when the notification was created|
    |NotificationId|The notification id to be sent|
    |SubscriptionName|The name of the subscription interested in the notification|
    |Channel|A channel object indicating the destination for the notification|
    |Status|An enumeration string indicating whether the transmission failed, was sent, was resending, was acknowledged, or was escalated|
    |ResendCount|Number indicating the number of resent attempts|
    |Records|An array of TransmissionRecords|
=== "TransmissionRecord"
    |Property|Description|
    |---|---|
    ||Information the status and response of a notification sent to a receiver|
    |Status|An enumeration string indicating whether the transmission failed, was sent, was acknowledged, or escalated|
    |Response|The response string from the receiver|
    |Sent|A timestamp indicating when the notification was sent|

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


### V3 Configuration Migration Guide
No configuration updated

See [Common Configuration Reference](../../../configuration/V3MigrationCommonConfig/) for complete details on common configuration changes.
### Gmail Configuration Example

Before using Gmail to send alerts and notifications, configure the
sign-in security settings through one of the following two methods:

1.  Enable 2-Step Verification and use an App Password (Recommended). An
    App password is a 16-digit passcode that gives an app or device
    permission to access your Google Account. For more detail about this
    topic, please refer to this 
    [Google official document](https://support.google.com/accounts/answer/185833?hl=en).
2.  Allow less secure apps: If the 2-Step Verification is not enabled,
    you may need to allow less secure apps to access the Gmail account.
    Please see the instruction from this 
    [Google official document](https://support.google.com/accounts/answer/6010255?hl=en).
    

Then, use the following settings for the mail server properties:

    Smtp Port=25
    Smtp Host=smtp.gmail.com
    Smtp Sender=${Gmail account}
    Smtp Password=${Gmail password or App password}

### Yahoo Mail Configuration Example 

Similar to Gmail, configure the sign-in security settings for Yahoo
through one of the following two methods:

1.  Enable 2-Step Verification and use an App Password (Recommended).
    Please see this Yahoo official document for more detail:
    <https://help.yahoo.com/kb/SLN15241.html>.
2.  Allow apps that use less secure sign in. Please see this Yahoo
    official document for more detail on this topic:
    <https://help.yahoo.com/kb/SLN27791.html>.

Then, use the following settings for the mail server properties:

    Smtp Port=25
    Smtp Host=smtp.mail.yahoo.com
    Smtp Sender=${Yahoo account}
    Smtp Password=${Yahoo password or App password}

#### Writable

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

## API Reference

[Support Notifications API Reference](../../../api/support/Ch-APISupportNotifications.md)
