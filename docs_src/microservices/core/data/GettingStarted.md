# Core Data

## Getting Started

### Overview

Core Data is one of the core EdgeX Services. It is needed for applications that require Events/Readings to be persisted.
For solutions that do not require storage and access to Events and Readings, it is possible to use the EdgeX framework without Core Data.

### Running Services with Core Data

The simplest way to run all the required services is to use the [Compose Builder](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder) tool from a terminal window.

1. Clone [https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}})

2. Change to the **compose-builder** folder

3. Run the services
    ```
    make run no-secty
    ```
This runs, in non-secure mode, all the standard EdgeX services, including core-data, along with the Device Virtual.
Core Data will use the Redis database as its datastore.

### Running Services without Core Data

The simplest way to run all the required services is to use the [Compose Builder](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}/compose-builder) tool from a terminal window.

1. Clone [https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}}](https://github.com/edgexfoundry/edgex-compose/tree/{{edgexversion}})

2. Change to the **compose-builder** folder

3. Generate a compose file
    ```
    make gen no-secty
    ```
4. Remove core-data from the compose file and resolve any depends on for core-data.
5. Run the compsoe file.
    ```
   docker compose -p edgex -f docker-compose.yml up -d
   ```

This runs, in non-secure mode, all the standard EdgeX services, except for core data, along with the Device Virtual.
Core Data will use the Redis database as its datastore.