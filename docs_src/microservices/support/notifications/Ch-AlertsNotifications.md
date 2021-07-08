# Alerts & Notifications

![image](EdgeX_SupportingServicesAlertsNotifications.png)

## Introduction

When another system or a person needs to know that something occurred in EdgeX, the
alerts and notifications micro service sends that notification.
Examples of alerts and notifications that other services could broadcast, include the provisioning of a new device, sensor data detected outside of certain parameters
(usually detected by a device service or rules engine) or system or service
malfunctions (usually detected by system management services).

### Terminology

**Notifications** are informative, whereas **Alerts** are typically of a
more important, critical, or urgent nature, possibly requiring immediate
action.

![image](EdgeX_SupportingServicesAlertsArchitecture.png)

This diagram shows the high-level architecture of the notification service.
On the left side, the APIs are provided for other
micro services, on-box applications, and off-box applications to use.  The APIs could be in REST, AMQP, MQTT, or any standard application
protocols. 

!!! Warning
    Currently in EdgeX Foundry, only the RESTful interface is provided.

On the right side, the notification receiver could be a person or an
application system on Cloud or in a server room. By invoking the
Subscription RESTful interface to subscribe the specific types of
notifications, the receiver obtains the appropriate notifications
through defined receiving channels when events occur. The receiving
channels include SMS message, e-mail, REST callback, AMQP, MQTT, and so
on. 

!!! Warning
    Currently in EdgeX Foundry, e-mail and REST callback channels are provided.

When the notification service receives notifications from any interface, 
the notifications are passed to the Notifications Handler internally. 
The Notifications Handler persists the received notifications first, 
and passes them to the Distribution Coordinator immediately when a 
given notification is either **critical** (severity = “CRITICAL”) or to the Message Scheduler when 
it is **normal** (severity = “NORMAL”).

When the Distribution Coordinator receives a notification, it first
queries the Subscription database to get receivers who need this
notification and their receiving channel information. According to the
channel information, the Distribution Coordinator passes this
notification to the corresponding channel senders. Then, the channel
senders send out the notifications to the subscribed receivers.

### Workflow

#### Normal Notifications
When a client requests a notification to be sent with "NORMAL" status, the notification is queued up (batched with other normal notifications).  The Message Scheduler, under a configurable interval, calls on the Distribution Coordinator to send all normal notifications to their receivers.  When a normal notification fails to be sent, it is retried a configurable number of times (resend limit).  After exceeding the resent tries, the notification is elevated to "CRITICAL" status and then sent through the critical notifications workflow below.

#### Critical Notifications
Notifications that are sent with "CRITICAL" status, or notifications that have failed to send via the NORMAL workflow are immediately sent to their receivers via the Distribution Coordinator.  If a critical notification fails to send for a specified number of retries, the service escalates the notification in order to notify an escalation subscriber of the failure to notify the receiver.

## Data Model

![image](EdgeX_SupportingServicesNotificationsModel.png)

## Data Dictionary

=== "Channel"
    |Property|Description|
    |---|---|
    ||The object used to describe the notification end point.  Channel supports transmissions and notifications with fields for delivery via email or REST|
    |Type|object of ChannelType - indicates whether the channel facilitates email or REST|
    |MailAddresses|An array of string email addresses|
    |Url|A string REST API destination endpoint|
=== "Notification"
    |Property|Description|
    |---|---|
    ||The object used to describe the message and sender content of a notification.|
    |ID|Uniquely identifies an notification, for example a UUID|
    |Slug|acts as the name of the notification|
    |Sender|a string indicating the notification message sender|
    |Category|an enumeration string indicating whether the notification is about software health, hardware health or a security issue|
    |Severity|an enumeration string indicating the severity of the notification - as either normal or critical|
    |Content|The message sent to the receivers|
    |Description|Human readable description explaining the reason for the notification or alert|
    |Status|an enumeration string indicating the status of the notification as new, processed or escalated|
    |Labels|array of associated means to label or tag a notification for better search and filtering|
    |ContentType|string indicating the type of content in the notification message|
=== "Transmission"
    |Property|Description|
    |---|---|
    ||The object used to group Notifications|
    |ID|Uniquely identifies an transmission, for example a UUID|
    |Notification|a notification object - the message and sender content|
    |Receiver|a string indicating the intended receiver of the notification|
    |Channel|a channel object indicating the destination for the notification|
    |Status|an enumeration string indicating whether the transmission failed, was sent, was acknowledged, or was escalated|
    |ResendCount|number indicating the number of resent attempts|
    |Records|an array of TransmissionRecords|
=== "TransmissionRecord"
    |Property|Description|
    |---|---|
    ||Information the status and response of a notification sent to a receiver|
    |Status|an enumeration string indicating whether the transmission failed, was sent, was acknowledged, or escalated|
    |Response|the response string from the receiver|
    |Sent|A timestamp indicating when the notification was sent|

## High Level Interaction Diagrams

This section shows the sequence diagrams for some of the more critical
or complex events regarding alerts and notifications.

**Critical Notifications Sequence**

When receiving a critical notification (SEVERITY = "CRITICAL"), it
persists first and triggers the distribution process immediately. After
updating the notification status, Alerts and Notifications respond to
the client to indicate the notification has been accepted.

![image](EdgeX_SupportingServicesCriticalNotifications.png)

**Normal Notifications Sequence**

When receiving a normal notification (SEVERITY = "NORMAL"), it persists
first and responds to the client to indicate the notification has been
accepted immediately. After a configurable duration, a scheduler
triggers the distribution process in batch.

![image](EdgeX_SupportingServicesNormalNotifications.png)

**Critical Resend Sequence**

When encountering any error during sending critical notification, an
individual resend task is scheduled, and each transmission record
persists. If the resend tasks keeps failing and the resend count exceeds
the configurable limit, the escalation process is triggered. The
escalated notification is sent to particular receivers of a special
subscription (slug = "ESCALATION").

![image](EdgeX_SupportingServicesCriticalResend.png)

**Resend Sequence**

For other non-critical notifications, the resend operation is triggered
by a scheduler.

![image](EdgeX_SupportingServicesResend.png)

**Cleanup Sequence**

Cleanup service removes old notification and transmission records.

![image](EdgeX_SupportingServicesCleanup.png)

## Configuration Properties

Please refer to the general [Common Configuration documentation](../../configuration/CommonConfiguration.md) for configuration properties common to all services.

=== "Writable"
    |Property|Default Value|Description|
    |---|---|---|
    |||Writable properties can be set and will dynamically take effect without service restart|
    |ResendLimit|2|Sets the retry limit for attempts to send notifications.  NORMAL notifications are make CRITICAL after exceeding the resend limit.  CRITICAL notifications are sent to the escalation subscriber when resend limit is exceeded.|
=== "Service"
    |Property|Default Value|Description|
    |---|---|---|
    |MaxResultCount|50000|Maximum number of objects (example: notifications) that are to be returned on any query of notifications database via its API|
=== "Databases/Databases.Primary"
    |Property|Default Value|Description|
    |---|---|---|
    |||Properties used by the service to access the database|
    |Host|'localhost'|Host running the notifications persistence database|
    |Name|'notifications'|Document store or database name|
    |Password|'password'|Password used to access the database|
    |Username|'notifications'|Username used to access the database|
    |Port|6379|Port for accessing the database service - the Redis port by default|
    |Timeout|5000|Database connection timeout in milliseconds|
    |Type|'redisdb'|Database to use - either redisdb or mongodb|
=== "Smtp"
    |Property|Default Value|Description|
    |---|---|---|
    |||Config to connect to applicable SMTP (email) service. All the properties with prefix "smtp" are for mail server configuration. Configure the mail server appropriately to send alerts and notifications. The correct values depend on which mail server is used.|
    |Smtp Host|smtp.gmail.com |SMTP service host name|
    |Smtp Port|587 | SMTP service port number|
    |Smtp EnableSelfSignedCert | false | Indicates whether a self-signed cert can be used for secure connectivity. |
    |Smtp Username | username@mail.example.com | A username for authentications with the Smtp server, if required. |
    |Smtp Password|(empty string)|SMTP service host access password|
    |Smtp Sender|jdoe@gmail.com |SMTP service sender/username|
    |Smtp Subject|EdgeX Notification|SMTP notification message subject|

### Gmail Configuration Example

Before using Gmail to send alerts and notifications, configure the
sign-in security settings through one of the following two methods:

1.  Enable 2-Step Verification and use an App Password (Recommended). An
    App password is a 16-digit passcode that gives an app or device
    permission to access your Google Account. For more detail about this
    topic, please refer to this Google official document:
    <https://support.google.com/accounts/answer/185833>.
2.  Allow less secure apps: If the 2-Step Verification is not enabled,
    you may need to allow less secure apps to access the Gmail account.
    Please see the instruction from this Google official document on
    this topic: <https://support.google.com/accounts/answer/6010255>.

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

## API Reference
[Support Notifications API Reference](../../../api/support/Ch-APISupportNotifications.md)
