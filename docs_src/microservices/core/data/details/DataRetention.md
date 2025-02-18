---
title: Core Data - Data Retention and Persistent Caps
---

# Core Data - Data Retention and Persistent Caps

!!! edgey "EdgeX 4.0"
    Enhance the original design in EdgeX 4.0, the Core Data service purges events by specified auto event source and retention policy.

## Overview

In use cases, since core data persists data in the local database indefinitely, there is a need to persist the latest recent events/readings only and clean up the old ones, as keeping an infinite number of events/readings is considered computationally expensive and can lead to a lack of machine memory. Thus, a retention mechanism is placed on core data to keep events and readings.

## Configure the Retention Policy

### Define the Retention Policy in the AutoEvent
You can define the `retention policy` in the `auto event` when adding or updating the device data as shown below. The Core Data service will apply the default retention values if you do not define them or set them to zero, and will perform time-based or count-based event retention according to the retention policy.

```json
"device": {
  "name": "testDevice",
  ...
  "profileName": "testProfile",
  "autoEvents": [
    { "interval": "10s", "onChange": false, "sourceName": "INT16_0" },  <= apply the default maxCap, minCap, and duration from the configuration file
    { "interval": "10s", "onChange": false, "sourceName": "INT16_1", "retention": {"maxCap": 0, "minCap": 1000, "duration": "30m"}},  <= apply the default maxCap from the configuration file
    { "interval": "10s", "onChange": false, "sourceName": "INT16_2", "retention": {"maxCap": 2000, "minCap": 0, "duration": "30m"}},  <= apply the default minCap from the configuration file
    { "interval": "10s", "onChange": false, "sourceName": "INT16_2", "retention": {"maxCap": 2000, "minCap": 1000, "duration": ""}},  <= apply the default duration from the configuration file
    { "interval": "10s", "onChange": false, "sourceName": "INT16_3", "retention": {"maxCap": 2000, "minCap": 1000, "duration": "30m"}}
  ]
}
```

* If Retention is not defined, the default values will be applied from the configuration.yaml. 
* `MaxCap` is the maximum events capacity, the high watermark of events should be detected for purging the amount of the event to the minimum capacity, you can disable the high watermark detection by setting `MaxCap` = `-1`. 
* `MinCap` is the minimum capacity of the event, the total count of event should be kept in Core Data after purging. you can purge all event if set `MinCap` = `-1`
* `Duration` is the duration to keep the event, the expired events should be detected for purging, and the service can keep old events if `MinCap` is not `-1`, you can disable the expired checking if set `duration` to "0s". Valid time units are "s", "m", "h", e.g., "1.5h" or "2h45m".

### Define the Retention Trigger interval and Default Policy
The Core Data service trigger the event purging process according to the retention `interval` defined in the configuration.yml file.
```yaml
Retention: 
  Interval: "10m"
  DefaultMaxCap: -1
  DefaultMinCap: 1      
  DefaultDuration: "168h"
```

* `Interval` default value is "10m", you can disable the event purging process by using "0s". Valid time units are "s", "m", "h", e.g., "1.5h" or "2h45m".
* `DefaultMaxCap` is the default maximum events capacity, and the default value is -1.
* `DefaultMinCap` is the default minimum events capacity, and the default value is 1. Be careful to use `minCap`, since the database uses offset to count the rows, the value becomes larger, and the database needs more time to count the rows.
* `DefaultDuration` is the default duration to keep the event, the default value is "168h".

## Usage

### Count-based Retention 
You can define `maxCap` and `minCap` for count-based retention.

```json
 "device": {
     "name": "device_int_autoevents",
     ...
     "profileName": "profile_int_resources",
     "autoEvents": [
         { 
             "interval": "1s", "onChange": false, "sourceName": "INT16_1", 
             "retention": {
                "maxCap": 2000, 
                "minCap": 1000, 
                "duration": "0s"
             }
          }
       ]
}
```
In this case, the Core Data service checks whether the event count is greater than 2000. If the count is 2000 or more, it purges events to maintain the `minCap` of 1000. If `minCap` is -1, the service removes all old data.

### Time-based Retention Without MinCap
You can define the `duration` to purge events for time-based retention.

```json
"device": {
    "name": "device_int_autoevents",
    ...
    "profileName": "profile_int_resources",
    "autoEvents": [
        { 
            "interval": "1s", "onChange": false, "sourceName": "INT16_1", 
            "retention": {
                "maxCap": -1, 
                "minCap": -1, 
                "duration": "24h"
            }
        }
    ]
}
```
In this case, the `minCap` is -1 which means we don't keep old data, then the Core Data purge events that the age(current time - event origin) is greater than "24h".

### Time-based Retention With MinCap
You can define the `duration` and `minCap` for time-based retention, while also ensuring a minimum number of expired events are kept in the database. Note that the minCap is used to retain old data when purging events. Even if the database contains new data, the process will still keep some old data. This is useful in cases where the device unexpectedly shuts down, and we want to preserve old data for tracing purposes.

```json
"device": {
    "name": "device_int_autoevents",
    ...
    "profileName": "profile_int_resources",
    "autoEvents": [
        { 
            "interval": "1s", "onChange": false, "sourceName": "INT16_1", 
            "retention": {
                "maxCap": -1, 
                "minCap": 1000, 
                "duration": "24h"
            }
        }
    ]
}
```
In this case, the Core Data service purges events that the age(current time - event origin) exceeds "24h" and leaves 1000 old events in DB. 

The Core Data service identifies the most recent 1000th event. If the 1000th event does not exist, the service skips purging. Otherwise, it removes expired data older than the 1000th event.

### The time-based retention with `maxCap` and `minCap`

!!! Note
    It is generally recommended not to configure both count-based and time-based retention policies at the same time, as this can lead to unnecessary complexity and potential confusion.

The user can combine count-based and time-based retention by defining the `maxCap`, `minCap`, and `duration`.
	
```json
"device": {
"name": "device_int_autoevents",
...
"profileName": "profile_int_resources",
"autoEvents": [
    { 
        "interval": "1s", "onChange": false, "sourceName": "INT16_1", 
        "retention": {
            "maxCap": 2000, 
            "minCap": 1000, 
            "duration": "24h"
        }
    }
]
}
```
In this case, the Core Data service checks whether the event count is greater than 2000. If the count is 2000 or more, it performs time-based retention as described in the previous section.

## Prerequisite Knowledge

- For detailed information on data retention, see [Core Data Configuration Properties](../Configuration.md) under the **retention** tab.
- For additional details, see [Notifications Configuration Properties](../../../support/notifications/Configuration.md#configuration-properties) under the **retention** tab.

## Enable Data Retention

The data retention mechanism is enabled by default. You can disable it by setting the retention interval to `0s`.

- Using environment variables to override the default configuration:

```yaml
RETENTION_INTERVAL: <interval>  
RETENTION_DEFAULTMAXCAP: <maxcap>
RETENTION_DEFAULTMINCAP: <mincap>
RETENTION_DEFAULTDURATION: <duration>  
```

For detailed information about environment variables override see [Service Configuration Overrides](../../../configuration/CommonEnvironmentVariables.md#service-configuration-overrides).

- Using Core Keeper to override the default configuration, for example, Update Retention's MinCap of core-data from `8000` to `10000`, refer to the [Core Keeper API documentation](../../../../api/core/Ch-APICoreKeeper.md) for more information.

```shell
curl -X PUT "http://localhost:59890/api/v3/kvs/key/edgex/{{config_version}}/core-data/Retention/MinCap" \
-H "Content-Type: application/json" \
-d '{"value": "10000"}'
```
