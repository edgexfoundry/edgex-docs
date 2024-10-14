---
title: Support Cron Scheduler - Data Retention and Persistent Caps
---

# Support Cron Scheduler - Data Retention and Persistent Caps

## Overview

### Support Cron Scheduler service
In use cases, since support-cron-scheduler service persists data in the local database indefinitely, there is a need to persist the latest recent schedule action records (hereafter referred to as records) only and clean up the old ones, as keeping an infinite number of records is considered computationally expensive and can lead to a lack of machine storage. Thus, a retention mechanism is placed on support-cron-scheduler to keep a certain number of records.

Under this mechanism, the maximum records capacity is called <code>MaxCap</code> and the minimum records capacity is called <code>MinCap</code>. Support Cron Scheduler will create an internal schedule according to the <code>Interval</code> configuration to check if the number of records are higher than the <code>MaxCap</code>. When the number of records reach the <code>MaxCap</code>, Support Cron Scheduler will purge the amount of the records to the <code>MinCap</code>.

For example, the <code>MaxCap</code> is set to 10, the <code>MinCap</code> is set to 2 and the <code>Interval</code> is set to 3s. Now, support-cron-scheduler will check how many records are in the local database every 3 seconds. When the number of records reach 10, support-cron-scheduler will check the latest record to find the created timestamp and perform function <code>DeleteScheduleActionRecordByAge</code> to delete records by age.

## Prerequisite Knowledge

- For detailed information on the data retention see [Support Cron Scheduler Configuration](../Configuration.md) and browse to **retention** tab.

## Disable Data Retention
The retention policy is enabled by defaut in support-cron-scheduler, and here is the way to disable data retention mechanism:

- Using environment variables to override the default configuration
```yaml
RETENTION_ENABLED: false
```

For detailed information about environment variables override see [Service Configuration Overrides](../../../configuration/CommonEnvironmentVariables.md#service-configuration-overrides).
