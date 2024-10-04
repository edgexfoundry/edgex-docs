---
title: Support Cron Scheduler - Getting Started
---

# Support Cron Scheduler - Getting Started

Support Cron Scheduler is one of the EdgeX Support Services which aims to replace the old Support Scheduler serivce.

It is needed for applications that require actions to occur on specific intervals or a scheduled time.

For solutions that do not require regular actions, it is possible to use the EdgeX framework without support cron scheduler.

## Terminology
### ScheduleJob
A schedule job contains the required information to scheduled one or more [ScheduleActions](#scheduleaction).

### ScheduleAction
A schedule action contains the required information for operating a specific action via a chosen type, which can be "REST", "EDGEXMESSAGEBUS", or "DEVICECONTROL".

Examples of schedule action include:

1. **REST**: A RESTful API call to a specific EdgeX service.
    ```
    {
        "type": "REST",
        "address": "http://edgex-core-data:59880/api/v3/ping",
        "method": "GET",
        "contentType": "application/json"
    }
    ```
2. **EDGEXMESSAGEBUS**: Sends a message to a specific topic on the EdgeX message bus.
    ```
    {
        "type": "EDGEXMESSAGEBUS",
        "topic": "edgex/trigger_app_service",
        "contentType": "application/json",
        "payload": { "key": "value" }
    }
    ```
    Above is an example of leveraging EdgeX message bus to trigger an app service at a specific time.
    Here is the corresponding app service configuration may look like:
    ```
    Trigger:
        Type: "edgex-messagebus"
        SubscribeTopics: "edgex/trigger_app_service/#"
    ```
    For more configuration details, please refer to the [App Service Configuration](../../application/details/Triggers.md#messagebus-connection-configuration).
3. **DEVICECONTROL**: Issues a command of a specific device and resouce.
    ```
    {
        "type": "DEVICECONTROL",
        "deviceName": "Random-Boolean-Device",
        "sourceName": "Bool",
        "contentType": "application/json",
        "payload": { "Bool": true }
    }
    ```
!!! note
    The payload can be an JSON object or a base64 encoded string.

### ScheduleDefinition
A schedule definition specifies an interval (type **INTERVAL**) or a crontab expression (type **CRON**) for a scheduleJob to be triggered at a specific time.

Two optional fields are available for the schedule definition:

1. **startTimestamp**: The start Unix timestamp of the schedule job, in milliseconds.
2. **endTimestamp**: The end Unix timestamp of the schedule job, in milliseconds.

Examples of schedule definition include:

1. **INTERVAL**: A schedule job will be triggered every 5 minutes since August 28, 2024 12:00:00 AM GMT until September 1, 2024 12:00:00 AM GMT.
    ```
    {
        "type": "INTERVAL",
        "interval": "5m",
        "startTimestamp": "1724803200000",
        "endTimestamp": "1725148800000"
    }
    ```
2. **CRON**: A schedule job will be triggered at 12:00 AM every day in the Asia/Taipei timezone.
    ```
    {
        "type": "CRON",
        "crontab": "CRON_TZ=Asia/Taipei 0 0 0 * * *"
    }
    ```
!!! note
    The crontab expression supports the [cron syntax](https://en.wikipedia.org/wiki/Cron) with an optional second field and a timezone field.

### ScheduleActionRecord
A schedule action record records the information of a [ScheduleAction](#scheduleaction), including the job name, action detail, scheduled time, and the status of the job which can be "SUCCEEDED", "FAILED", or "MISSED".

!!! note
    The "MISSED" records will be calculated and created by the cron scheduler service when the service is restarted.
    
    An optional field autoTriggerMissedRecords is available for each scheduled job, allowing actions to be triggered once automatically when the service restarts and there are any missed records. Default is false.

## Running Services with Support Cron Scheduler

Please refer to [Using PostgreSQL Database](../../general/database/Ch-Postgres/#using-postgresql-database) for instructions on how to get EdgeX services up and running with PostgreSQL database.
Following the steps in this guide, the Support Cron Scheduler service will be included among the services that are started.

<!-- TODO -->
<!-- ## Running Services without Support Cron Scheduler -->
