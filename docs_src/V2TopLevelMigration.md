# V2 Migration Guide

!!! edgey "EdgeX 2.0"
    Many backward breaking changes occurred in the EdgeX 2.0 (Ireland) release which may require some migration depending on your use case.

This section describes how to migrate from EdgeX 1.x to EdgeX 2.0 at a high level and refers the reader to the appropriate detail documents. The areas to consider for migrating are:

- [Custom Compose File](#custom-compose-file)
- [Database](#database)
- [Custom Configuration](#custom-configuration)
- [Custom Device Service](#custom-device-service)
- [Custom Applications Service](#custom-applications-service)

## Custom Compose File

The compose files for V2 have many changes from their V1 counter parts. If you have customized a V1 compose file to add additional services or tweak overrides,  it is highly recommended that you start with the appropriate V2 compose file and re-add your customizations. It is very likely that the sections for your additional services will need to be migrated to have the proper environment overrides. Best approach is to use one of the V2 service sections that closest matches your service  as a template.

The latest V2 compose files can be found here: [https://github.com/edgexfoundry/edgex-compose/tree/ireland](https://github.com/edgexfoundry/edgex-compose/tree/ireland)

### Compose Builder

If the add on service(s) in your custom compose file are EdgeX released device or app services, it is highly recommended that you use the Compose Builder to generate your custom compose file. 

The latest V2 Compose Builder can be found here: [https://github.com/edgexfoundry/edgex-compose/tree/ireland/compose-builder#readme](https://github.com/edgexfoundry/edgex-compose/tree/ireland/compose-builder#readme)

## Database

There currently is no migration path for the data stored in the database. The V2 data collections are stored separately from the V1 data collections in the Redis database. Redis is now the only supported database, i.e. support for Mongo has been removed.

!!! note
    Since the V1 data and V2 data are stored separately, one could create a migration tool and upstream it to the EdgeX community.

!!! warning
    If the database is not cleared before starting the V2 services, the old V1 data will still reside in the database taking up useful memory. It is recommended that you first wipe the database clean before starting EdgeX 2.0 Services. That is unless you create a DB migration tool. See [Clearing Redis Database](#clearing-redis-database) section below for details on how to clear the Redis database.

The following sections describe what you need to be aware for the different services that create data in the database.

### Core Data

The Event/Reading data stored by Core Data is considered transient and of little value once it has become old. The V2 versions of these data collections will be empty until new Events/Readings are received from V2 Device Services. 

The V1 ValueDescriptors have be remove in V2.

### Core Metadata

Most of the data stored by Core Metadata will be recreated when the V2 versions of the Device Services start-up. The statically declared devices will automatically be created and device discovery will find and add existing devices. Any device profiles, devices, provision watchers created manually via the V1 REST API will have to be recreated using the V2 REST API. Any manually-applied `AdministrativeState` settings will also need to be re-applied.

### Support Notifications

Any `Subscriptions` created via the V1 REST API will have to be recreated using the V2 REST API. The `Notification` and `Transmission`collections will be empty until new notifications are sent using EdgeX 2.0 

### Support Scheduler

The statically declared `Interval` and `IntervalAction` will be created automatically. Any `Interval` and/or `IntervalAction` created via the V1 REST API will have to be recreated using the V2 REST API. If you have created a custom configuration with additional statically declared `Interval`s and `IntervalActions` see the [TOML File](#tomml-file) section under [Custom Configuration](#custom-configuration) below.

### Application Services

Application services use the database only when the [Store and Forward](../microservices/application/AdvancedTopics/#store-and-forward) capability is enabled. If you do not use this capability you can skip this section. This data collection only has data when that data could not be exported. It is recommended not to upgrade to V2 while the Store and Forward data collection is not empty or you are certain the data is no longer needed. You can determine if the Store and Forward data collection is empty by setting the Application Service's log level to `DEBUG`  and look for the following message which is logged every `RetryInterval`:

```tex
msg=" 0 stored data items found for retrying"
```

### Clearing Redis Database

#### Docker

When running EdgeX in Docker the simplest way to clear the database is to remove the `db-data` volume after stopping the V1 EdgeX services. 

```console
docker-compose -f <compose-file> down
docker volume rm $(docker volume ls -q | grep db-data)
```

Now when the V2 EdgeX services are started the database will be cleared of the old v1 data.

#### Snaps

TBD 

## Custom Configuration

### Consul

If you have customized any EdgeX service's configuration  (core, support, device, etc.)  via Consul, those customization will need to be re-applied to those services' configuration in Consul once the V2 versions have started and pushed their configuration into Consul. The V2 services now use `2.0` in the Consul path rather than `1.0` . See the [TOML File](#toml-file) section below for details on migrating configuration for each of the EdgeX services.

!!! example "Example Consul path for V2"
    .../kv/edgex/core/2.0/core-data/

The same applies for custom device and application service once they have been migrated following the guides referenced in the [Custom Device Service](custom-device-service) and [Custom Applications Service](custom-applications-service) sections below.

!!! warning
    If the Consul data is not cleared prior to running the V2 services,  the V1 configuration will remain and be taking up useful memory.  The configuration data in Consul can be cleared by deleting the `.../kv/edgex/` node with this curl command:

    ````
    curl --request DELETE http://localhost:8500/v1/kv/edgex?recurse=true`
    ````

### TOML File

If you have custom configuration TOML files for any EdgeX service (core, support, device, etc.) that configuration will need to be migrated. See [V2 Migration of Common Configuration](../microservices/configuration/V2MigrationCommonConfig/) for the details on migrating configuration common to all EdgeX services.

The following are where you can find the configuration migration specifics for individual core/support the services

- [Core Data](../microservices/core/data/Ch-CoreData/#v2-configuration-migration-guide) 
- [Core Metadata](../microservices/core/metadata/Ch-Metadata/#v2-configuration-migration-guide) 
- [Core Command](../microservices/core/command/Ch-Command/#v2-configuration-migration-guide)
- [Support Notifications](../microservices/support/notifications/Ch-AlertsNotifications/#v2-configuration-migration-guide)
- [Support Scheduler](../microservices/support/scheduler/Ch-Scheduler/#v2-configuration-migration-guide)
- [System Management Agent](../microservices/system-management/agent/Ch_SysMgmtAgent/#v2-configuration-migration-guide)  (DEPRECATED)
- [Application Services](../microservices/application/V2Migration/#configuration)
- [Device Services (common)](../microservices/device/V2Migration/#configuration)
- Device MQTT (TBD)
- Device Camera (TBD)

### Custom Environment Overrides

If you have custom [environment overrides](../microservices/configuration/CommonEnvironmentVariables/#environment-overrides) for configuration impacted by the V2 changes you will also need to migrate your overrides to use the new name or value depending on what has changed. Refer to the links above and/or below for details for migration common and/or the service specific configuration to determine if your overrides require migrating.

## Custom Device Service

If you have custom Device Services they will need to be migrated to the V2 version of the Device SDK.  See [Device Service V2 Migration Guide](../microservices/device/V2Migration) for complete details.

## Custom Applications Service

 If you have custom Application Services they will need to be migrated to the V2 version of the App Functions SDK. See [Application Services V2 Migration Guide](../microservices/application/V2Migration) for complete details.

