# Data Retention and Persistent Caps

!!! edgey "EdgeX 3.1"
    New in EdgeX 3.1

!!! note
    This feature is for both Core Data and Support Notifications service.

## Overview

### Core Data service
In use cases, since core data persists data in the local database indefinitely, there is a need to persist the latest recent readings only and clean up the old ones, as keeping an infinite number of readings is considered computationally expensive and can lead to a lack of machine memory. Thus, a retention mechanism is placed on core data to keep a certain number of readings.

Under this mechanism, the maximum readings capacity is called <code>MaxCap</code> and the minimum readings capacity is called <code>MinCap</code>. Core data will create an internal schedule according to the <code>Interval</code> configuration to check if the number of readings are higher than the <code>MaxCap</code>. When the number of readings reach the <code>MaxCap</code>, Core data will purge the amount of the readings to the <code>MinCap</code>.

For example, the <code>MaxCap</code> is set to 10, the <code>MinCap</code> is set to 2 and the <code>Interval</code> is set to 3s. Now, core data will check how many readings are in the local database every 3 seconds. When the number of readings reach 10, core data will check the 3rd reading to find the related event's origin timestamp and perform function <code>DeleteEventsByAge</code> to delete events by age. This way the related readings will also be deleted.

### Support Notifications service
As with core data, the number of notification can increase indefinitely, so the same retention mechanism can be also used to keep the latest notification and clean up the old ones. 

## Introduction

For detailed information on the data retention see [Use Case for capping readings in Core Data](../design/ucr/Core-Data-Retention.md).

## Prerequisite Knowledge

- For detailed information on the data retention see [Core Data Configuration Properties](../microservices/core/data/Configuration.md) and browse to **retention** tab.

- For detailed information on the data retention see [Notifications Configuration Properties](../microservices/support/notifications/Ch-AlertsNotifications.md#configuration-properties) and browse to **retention** tab.

## Enable Data Retention
Two ways to enable data retention mechanism:

- Using environment variables to override the default configuration
```yaml
RETENTION_ENABLED: true 
RETENTION_INTERVAL: <interval>  
RETENTION_MAXCAP: <maxcap>
RETENTION_MINCAP: <mincap>  
```

For detailed information about environment variables override see [Service Configuration Overrides](../microservices/configuration/CommonEnvironmentVariables.md#service-configuration-overrides).

- Using <code>Consul</code> to override the default configuration
Open Consul web user interface and go to *Retention* section of the core-data or support-notification service to customize the configuarion.

For detailed information about Consul see [Configuration and Registry Provider](../microservices/configuration/ConfigurationAndRegistry.md#web-user-interface).