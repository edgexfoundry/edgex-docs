# Alerts & Notifications

![image](EdgeX_SupportingServicesAlertsNotifications.png)

## Introduction

When notification to another system or to a person, needs to occur to
notify of something discovered on the node by another microservice, the
Alerts and Notifications microservice delivers that information.
Examples of Alerts and Notifications that other services could need to
broadcast, include sensor data detected outside of certain parameters
(usually detected by a Rules Engine service) or system or service
malfunctions (usually detected by System Management services).
Terminology

**Notifications** are informative, whereas **Alerts** are typically of a
more important, critical, or urgent nature, possibly requiring immediate
action.

![image](EdgeX_SupportingServicesAlertsArchitecture.png)

The diagram shows the high-level architecture of Alerts and
Notifications. On the left side, the APIs are provided for other
microservices, on-box applications, and off-box applications to use, and
the APIs could be in REST, AMQP, MQTT, or any standard application
protocols. Currently in EdgeX Foundry, the RESTful interface is
provided.

On the right side, the notification receiver could be a person or an
application system on Cloud or in a server room. By invoking the
Subscription RESTful interface to subscribe the specific types of
notifications, the receiver obtains the appropriate notifications
through defined receiving channels when events occur. The receiving
channels include SMS message, e-mail, REST callback, AMQP, MQTT, and so
on. Currently in EdgeX Foundry, e-mail and REST callback channels are
provided.

When Alerts and Notifications receive notifications from any interface, 
the notifications are passed to the Notifications Handler internally. 
The Notifications Handler persists the received notifications first, 
and passes them to the Distribution Coordinator immediately when a 
given notification is either critical (severity = “CRITICAL”) or when 
it is normal (severity = “NORMAL”).

When the Distribution Coordinator receives a notification, it first
queries the subscription to acquire receivers who need to obtain this
notification and their receiving channel information. According to the
channel information, the Distribution Coordinator passes this
notification to the corresponding channel senders. Then, the channel
senders send out the notifications to the subscribed receivers.

## Data Model

MongoDB is selected for the persistence of Alerts and Notifications, so
the data model design is without foreign key and based on the paradigm
of document structure.

![image](EdgeX_SupportingServicesDataModel.png)

## Data Dictionary

  ------------------------------------------------------------------------
  **Class Name** **Description**
  -------------- ---------------------------------------------------------
  Channel        The object used to describe the Notification end point.

  Notification   The object used to describe the message and sender
                 content of a Notification.

  Transmission   The object used for grouping of Notifications.
  ------------------------------------------------------------------------

## High Level Interaction Diagrams

This section shows the sequence diagrams for some of the more critical
or complex events regarding Alerts and Notifications.

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

Please refer to the general Configuration [documentation](https://docs.edgexfoundry.org/1.2/microservices/configuration/Ch-Configuration/#configuration) for configuration properties common across all services.

Configuration specific to the Support-Notifications service is as follows. Changes made to any of these properties while the service is running will not be reflected until the service is restarted.

|Configuration|	Default Value	|Dependencies|
| --- | --- | --- |
|**Following config apply to using the SMTP service**|
|Smtp Host	|smtp.gmail.com |SMTP service host name|
|Smtp Port	|587 | SMTP service port number|
|Smtp EnableSelfSignedCert | false | Indicates whether a self-signed cert can be used for secure connectivity. |
|Smtp Username | username@mail.example.com | A username for authentications with the Smtp server, if requied. |
|Smtp Password	|mypassword |SMTP service host access password|
|Smtp Sender	|jdoe@gmail.com |SMTP service sendor/username|
|Smtp Subject	|EdgeX Notification	|SMTP alert message subject|
| | | |

## Configure Mail Server

All the properties with prefix "smtp" are for mail server
configuration. Configure the mail server appropriately to send Alerts
and Notifications. The correct values depend on which mail server is
used.

### Gmail

Before using Gmail to send Alerts and Notifications, configure the
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

### Yahoo Mail

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
