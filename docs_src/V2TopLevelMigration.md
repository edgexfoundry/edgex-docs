# V2 Migration Guide

!!! edgey "EdgeX 2.0"
    Many backward breaking changes occurred in the EdgeX 2.0 (Ireland) release which may require some migration depending on your use case.

This section describes how to migrate from V1 to V2  at a high level and refers the reader to the appropriate detail documents. The areas to consider for migrating are:

- [Custom Compose File](#custom-compose-file)
- [Database](#database)
- [Custom Configuration](#custom-configuration)
- [Custom Device Service](#custom-device-service)
- [Custom Device Profile](#custom-device-profile)
- [Custom Pre-Defined Device](#custom-pre-defined-device)
- [Custom Applications Service](#custom-applications-service)
- [Security](#security)
- [eKuiper Rules](#ekuiper-rules)

## Custom Compose File

The compose files for V2 have many changes from their V1 counter parts. If you have customized a V1 compose file to add additional services and/or add or modify configuration overrides,  it is highly recommended that you start with the appropriate V2 compose file and re-add your customizations. It is very likely that the sections for your additional services will need to be migrated to have the proper environment overrides. Best approach is to use one of the V2 service sections that closest matches your service  as a template.

The latest V2 compose files can be found here: [https://github.com/edgexfoundry/edgex-compose/tree/ireland](https://github.com/edgexfoundry/edgex-compose/tree/ireland)

### Compose Builder

If the add on service(s) in your custom compose file are EdgeX released device or app services, it is highly recommended that you use the Compose Builder to generate your custom compose file. 

The latest V2 Compose Builder can be found here: [https://github.com/edgexfoundry/edgex-compose/tree/ireland/compose-builder#readme](https://github.com/edgexfoundry/edgex-compose/tree/ireland/compose-builder#readme)

## Database

There currently is no migration path for the data stored in the database. The V2 data collections are stored separately from the V1 data collections in the Redis database. Redis is now the only supported database, i.e. support for Mongo has been removed.

!!! note
    Since the V1 data and V2 data are stored separately, one could create a migration tool and upstream it to the EdgeX community.

!!! warning
    If the database is not cleared before starting the V2 services, the old V1 data will still reside in the database taking up useful memory. It is recommended that you first wipe the database clean before starting V2 Services. That is unless you create a DB migration tool, in which case you will not want to clear the V1 data until it has been migrated. See [Clearing Redis Database](#clearing-redis-database) section below for details on how to clear the Redis database.

The following sections describe what you need to be aware for the different services that create data in the database.

### Core Data

The Event/Reading data stored by Core Data is considered transient and of little value once it has become old. The V2 versions of these data collections will be empty until new Events/Readings are received from V2 Device Services. 

The V1 ValueDescriptors have been removed in V2.

#### Reading

 The following are the fields that have changed, added or removed.

- `device` => `deviceName`
- `name` => `resourceName`
- `profileName` (**new**)
- `pushed` (**removed**)
- `created` (**removed** - use `origin`)
- `modified` (**removed** - use `origin`)
- `floatEncoding` (**removed**)
- `units` (**new**)
- `objectValue` (**new** since v2.1)

!!! example "Comparison between v1 and v2 Reading"

    ```
    V1 Reading:
    {
        "id": "500ef2d3-a80c-4bdf-b268-0aa7b1891721",
        "created": 1666768403135,
        "origin": 1666768403135266769,
        "device": "Random-Boolean-Device",
        "name": "Bool",
        "value": "true",
        "valueType": "Bool"
    }
    
    V2 Reading:
    {
        "id": "27f733a1-71a5-4002-a07b-a7785c86f68f",
        "origin": 1666767570746605009,
        "deviceName": "Random-Boolean-Device",
        "resourceName": "Bool",
        "profileName": "Random-Boolean-Device",
        "valueType": "Bool",
        "value": "true"
    }
    ```

#### Event

The following are the fields that have changed, added or removed.

- `apiVersion` (**new**)
- `device` => `deviceName`
- `sourceName` (**new**)
- `profileName` (**new**)
- `pushed` (**removed**)
- `created` (**removed** - use `origin`)
- `modified` (**removed** - use `origin`)

!!! example "Comparison between v1 and v2 Event"

    ```
    V1 Event:
    {
        "id": "a730daf1-9dcb-4112-9d77-8b714e4b39e1",
        "device": "Random-Boolean-Device",
        "created": 1666768353173,
        "origin": 1666768353172848489,
        "readings": [
            {
                "id": "92990d19-15fd-43c8-bcab-2d93142bb997",
                "created": 1666768353173,
                "origin": 1666768353172647726,
                "device": "Random-Boolean-Device",
                "name": "Bool",
                "value": "true",
                "valueType": "Bool"
            }
        ]
    }
    
    V2 Event:
    {
        "apiVersion": "v2",
        "id": "8b06a2dd-932a-4ae1-b9fd-86a76cf25b87",
        "deviceName": "Random-Boolean-Device",
        "profileName": "Random-Boolean-Device",
        "sourceName": "Bool",
        "origin": 1666767710656641395,
        "readings": [
            {
                "id": "56af9956-5e31-47df-89ca-e8b13d7c3dd9",
                "origin": 1666767710656641395,
                "deviceName": "Random-Boolean-Device",
                "resourceName": "Bool",
                "profileName": "Random-Boolean-Device",
                "valueType": "Bool",
                "value": "false"
            }
        ]
    }
    ```

### Core Metadata

Most of the data stored by Core Metadata will be recreated when the V2 versions of the Device Services start-up. The statically declared devices will automatically be created and device discovery will find and add existing devices. Any device profiles, devices, provision watchers created manually via the V1 REST APIs will have to be recreated using the V2 REST API. Any manually-applied `AdministrativeState` settings will also need to be re-applied.

### Support Notifications

Any `Subscriptions` created via the V1 REST API will have to be recreated using the V2 REST API. The `Notification` and `Transmission`collections will be empty until new notifications are sent using EdgeX 2.0 

### Support Scheduler

The statically declared `Interval` and `IntervalAction` will be created automatically. Any `Interval` and/or `IntervalAction` created via the V1 REST API will have to be recreated using the V2 REST API. If you have created a custom configuration with additional statically declared `Interval`s and `IntervalActions` see the [TOML File](#toml-file) section under [Custom Configuration](#custom-configuration) below.

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

Because there are no tools to migrate EdgeX configuration and database, it's not possible to update the edgexfoundry snap from a V1 version to a V2 version. You must remove the V1 snap first, and then install a V2 version of the snap (available from the 2.0 track in the Snap Store). This will result in starting fresh with EdgeX V2 and all V1 data removed.

#### Local

If you are running EdgeX locally, i.e. not in Docker or snaps and in **non-secure** mode you can use the Redis CLI to clear the database. The CLI would have been installed when you installed Redis locally. Run the following command to clear the database:

```
redis-cli FLUSHDB
```

This will not work if running EdgeX V1 in running in secure mode since you will not have the random generated Redis password unless you created an Admin password when you installed Redis.

## Custom Configuration

### Consul

If you have customized any EdgeX service's configuration  (core, support, device, etc.)  via Consul, those customization will need to be re-applied to those services' configuration in Consul once the V2 versions have started and pushed their configuration into Consul. The V2 services now use `2.0` in the Consul path rather than `1.0` . See the [TOML File](#toml-file) section below for details on migrating configuration for each of the EdgeX services.

!!! example "Example Consul path for V2"
    .../kv/edgex/core/2.0/core-data/

The same applies for custom device and application service once they have been migrated following the guides referenced in the [Custom Device Service](custom-device-service) and [Custom Applications Service](custom-applications-service) sections below.

!!! warning
    If the Consul data is not cleared prior to running the V2 services,  the V1 configuration will remain and be taking up useful memory.  The configuration data in Consul can be cleared by deleting the `.../kv/edgex/` node with the curl command below prior to starting EdgeX 2.0. Consul is secured in EdgeX 2.0 secure-mode which will make running  the command below require an access token if not done prior.

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
- [Device MQTT](../microservices/device/V2Migration/#device-mqtt)
- [Device Camera](../microservices/device/V2Migration/#device-camera)

### Custom Environment Overrides

If you have custom [environment overrides](../microservices/configuration/CommonEnvironmentVariables/#environment-overrides) for configuration impacted by the V2 changes you will also need to migrate your overrides to use the new name or value depending on what has changed. Refer to the links above and/or below for details for migration of common and/or the service specific configuration to determine if your overrides require migrating.

## Custom Device Service

If you have custom Device Services they will need to be migrated to the V2 version of the Device SDK.  See [Device Service V2 Migration Guide](../microservices/device/V2Migration) for complete details.

## Custom Device Profile

If you have custom V1 Device Profile(s) for one of the EdgeX Device Services they will need to be migrated to the V2 version of Device Profiles.  See [Device Service V2 Migration Guide](../microservices/device/V2Migration#device-profiles) for complete details.

## Custom Pre-Defined Device

If you have custom V1 Pre-Defined Device(s) for one of the EdgeX Device Services they will need to be migrated to the V2 version of Pre-Defined Devices.  See [Device Service V2 Migration Guide](../microservices/device/V2Migration/#pre-defined-devices) for complete details.

## Custom Applications Service

 If you have custom Application Services they will need to be migrated to the V2 version of the App Functions SDK. See [Application Services V2 Migration Guide](../microservices/application/V2Migration) for complete details.

## Security

### Settings

If you have an add-on service running in secure mode you will need to set addition security service environment variables in EdgeX V2. See [Configuring Add-on Service](../security/Ch-Configuring-Add-On-Services) for more details.

### API Gateway configuration

The API gateway has different tools to set TLS and acquire access tokens. See [Configuring API Gateway](../security/Ch-APIGateway/#configuring-api-gateway) section for complete details.

### Secure Consul

Consul is now secured when running EdgeX 2.0 in secured mode. See [Secure Consul](../security/Ch-Secure-Consul) section for complete details.

### Secured API Gateway Admin Port 

The API Gateway Admin port is now secured when running EdgeX 2.0 in secured mode. See API Gateway Admin Port (TBD) section for complete details.

## eKuiper Rules

If you have rules defined in the eKuiper rules engine that utilize the `meta()` directive, you will need to migrate your rule(s) to use the new V2  `meta` names. The following are the `meta` names that have changed, added or removed.

- device => deviceName
- name => resourceName
- profileName (**new**)
- pushed (**removed**)
- created (**removed** - use origin) 
- modified (**removed** - use origin) 
- floatEncoding (**removed**)

!!! example "Example V1 to V2 rule migration"

    ```
    V1 Rule:
    {
      "id": "ruleInt64",
      "sql": "SELECT Int64 FROM demo WHERE meta(device) = \"Random-Integer-Device\" ",
      "actions": [
        {
          "mqtt": {
            "server": "tcp://edgex-mqtt-broker:1883",
            "topic": "result",
            "clientId": "demo_001"
          }
        }
      ]
    }
    
    V2 Rule:
    {
      "id": "ruleInt64",
      "sql": "SELECT Int64 FROM demo WHERE meta(deviceName) = \"Random-Integer-Device\" ",
      "actions": [
        {
          "mqtt": {
            "server": "tcp://edgex-mqtt-broker:1883",
            "topic": "result",
            "clientId": "demo_001"
          }
        }
      ]
    }
    ```

