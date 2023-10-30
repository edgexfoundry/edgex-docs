---
title: Support Notification - Getting Started
---

# Support Notification - Getting Started

Support Notifications is one of the EdgeX Support Services. It is needed for applications that require notifications or alerts to be sent to the users.
For solutions that do not require notifications, it is possible to use the EdgeX framework without support notifications.

## Running Services with Support Notifications

The simplest way to run all the required services is to use the [Compose Builder](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder) tool from a terminal window.

1. Clone [https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}})

2. Change to the **compose-builder** folder

3. Run the services
    ```
    make run no-secty
    ```
This runs, in non-secure mode, all the standard EdgeX services, including support notifications, along with the Device Virtual.

## Running Services without Support Notifications
The simplest way to run all the required services is to use the [Compose Builder](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder) tool from a terminal window.

1. Clone [https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}})
2. Change to the **compose-builder** folder
3. Generate a compose file
    ```
    make gen no-secty ds-virtual
    ```
4. Remove support-notifications from the compose file and resolve any depends on for support notifications.
5. Run the compose file.
    ```
    make up
    ```

This runs, in non-secure mode, all the standard EdgeX services, except for support notifications, along with the Device Virtual.



## Terminology

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

## Workflow

### Normal/Minor Notifications
When a client requests a notification to be sent with "NORMAL" or "MINOR" status,
the notification is immediately sent to its receivers via the Distribution Coordinator,
and the status is updated to "PROCESSED".

### Critical Notifications
Notifications with "CRITICAL" status are also sent immediately.
When encountering any error during sending critical notification,
an individual resend task is scheduled, and each transmission record persists.
After exceeding the configurable limit (resend limit), the service escalates the notification
and create a new notification to notify particular receivers of the escalation subscription (name = "ESCALATION") of the failure.

!!! note
    All notifications are processed immediately. The resend feature is only provided for critical notifications.
    The **resendLimit** and **resendInterval** properties can be defined in each subscription.
    If the properties are not provided, use the default values in the configuration properties.
