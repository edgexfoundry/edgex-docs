---
title: Support Scheduler - Getting Started
---

# Support Scheduler - Getting Started

!!! Warning
    Support Scheduler service has been deprecated in EdgeX 4.0.  The service will not be immediately removed, but adopters should note that it has been tagged for eventual replacement.
    
    Use the new EdgeX Support Cron Scheduler service instead.  The Support Cron Scheduler service is a more flexible and powerful service that provides the same functionality as the Support Scheduler service, but with additional features and improvements.

    For more information on the Support Cron Scheduler service, see the [Support Cron Scheduler documentation](../cronScheduler/Purpose.md).

Support Scheduler is one of the core EdgeX Services. It is needed for applications that require actions to occur on specific intervals.
For solutions that do not require regular actions, it is possible to use the EdgeX framework without support scheduler.

## Running Services with Support Scheduler

The simplest way to run all the required services is to use the [Compose Builder](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder) tool from a terminal window.

1. Clone [https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}})

2. Change to the **compose-builder** folder

3. Run the services
    ```
    make run no-secty ds-virtual
    ```
This runs, in non-secure mode, all the standard EdgeX services, including support scheduler, along with the Device Virtual.

## Running Services without Support Scheduler
The simplest way to run all the required services is to use the [Compose Builder](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder) tool from a terminal window.

1. Clone [https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}})
2. Change to the **compose-builder** folder
3. Generate a compose file
    ```
    make gen no-secty ds-virtual
    ```
4. Remove support-scheduler from the compose file and resolve any depends on for support scheduler.
5. Run the compose file.
    ```
    make up
    ```
This runs, in non-secure mode, all the standard EdgeX services, except for support scheduler, along with the Device Virtual.
