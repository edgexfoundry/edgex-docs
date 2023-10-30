---
title: Support Scheduler - Getting Started
---

# Support Scheduler - Getting Started

Support Scheduler is one of the core EdgeX Services. It is needed for applications that require actions to occur on specific intervals.
For solutions that do not require regular actions, it is possible to use the EdgeX framework without support scheduler.

## Running Services with Support Scheduler

The simplest way to run all the required services is to use the [Compose Builder](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder) tool from a terminal window.

1. Clone [https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}})

2. Change to the **compose-builder** folder

3. Run the services
    ```
    make run no-secty
    ```
This runs, in non-secure mode, all the standard EdgeX services, including support scheduler, along with the Device Virtual.

## Running Services without Support Scheduler
The simplest way to run all the required services is to use the [Compose Builder](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder) tool from a terminal window.

1. Clone [https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}})
2. Change to the **compose-builder** folder
3. Generate a compose file
    ```
    make gen no-secty
    ```
4. Remove support-scheduler from the compose file and resolve any depends on for support scheduler.
5. Run the compose file.
    ```
    make up
    ```
This runs, in non-secure mode, all the standard EdgeX services, except for support scheduler, along with the Device Virtual.
