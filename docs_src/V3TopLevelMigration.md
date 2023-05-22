# V3 Migration Guide

!!! edgey "EdgeX 3.0"
    Many backward breaking changes occurred in the EdgeX 3.0 (Minnesota) release which may require some migration depending on your use case.

This section describes how to migrate from V2 to V3  at a high level and refers the reader to the appropriate detail documents. The areas to consider for migrating are:

- [Customized Configuration](#customized-configuration)
- [Custom Compose File](#custom-compose-file)
- [Command Line Options](#command-line-options)
- [Database](#database)
- [Custom Device Service](#custom-device-service)
- [Custom Device Profile](#custom-device-profile)
- [Custom Pre-Defined Device](#custom-pre-defined-device)
- [Custom Applications Service](#custom-applications-service)
- [Security](#security)
- [eKuiper](#ekuiper)

## Customized Configuration

Service configuration is one of the big changes for EdgeX V3

### Configuration Provider

If you have customized any EdgeX service's configuration  (core, support, device, etc.)  via the Configuration Provider (Consul), those customization will need to be re-applied to those services' configuration or the common configuration in the Configuration Provider once the V3 versions have started and pushed their configuration into the Configuration Provider. The V3 services now use `v3` in the Configuration Provider path rather than `2.0` . The folder structure in the Configuration Provider has  been flattened so all services are at the same level. See the [Configuration File](#configuration-file) section below for details on migrating configuration.

!!! example "Example Configuration Provider paths for V3"
    ```
    .../kv/edgex/v3/core-common-config-bootstrapper
    .../kv/edgex/v3/core-data/
    .../kv/edgex/v3/device-virtual/
    .../kv/edgex/v3/app-rules-engine/
    ```

The same applies for custom device and application service once they have been migrated following the guides referenced in the [Custom Device Service](#custom-device-service) and [Custom Applications Service](#custom-applications-service) sections below.

!!! warning
    If the Configuration Provider data is not cleared prior to running the V3 services,  the V2 configuration will remain and be taking up useful memory.  The configuration data in the Configuration Provider can be cleared by deleting the `.../edgex/` node with the curl command below prior to starting EdgeX 3.0. 
    ````
    curl --request DELETE http://localhost:8500/v1/kv/edgex?recurse=true`
    ````

### Configuration File

If you have customized the service configuration files for any EdgeX service (core, support, device, etc.) that configuration will need to be migrated. 

The biggest two changes to the service configuration files are:

1. File format has changed to YAML
2. Settings that are common have been removed from each service's local private configuration file

See [V3 Migration of Common Configuration](../microservices/configuration/V3MigrationCommonConfig/) for the details on migrating configuration common to all EdgeX services.

The [tool here](https://www.convertsimple.com/convert-toml-to-yaml/) can be used to convert your customized service configuration file from TOML to YAML. This should be done once all the common configuration has been removed.

The following are where you can find the configuration migration specifics for individual EdgeX services

- [Core Data](../microservices/core/data/Ch-CoreData/#v3-configuration-migration-guide) 
- [Core Metadata](../microservices/core/metadata/Ch-Metadata/#v3-configuration-migration-guide) 
- [Core Command](../microservices/core/command/Ch-Command/#v3-configuration-migration-guide)
- [Support Notifications](../microservices/support/notifications/Ch-AlertsNotifications/#v3-configuration-migration-guide)
- [Support Scheduler](../microservices/support/scheduler/Ch-Scheduler/#v3-configuration-migration-guide)
- [Application Services](../microservices/application/V3Migration/#configuration)
- [Device Services (common)](../microservices/device/V3Migration/#configuration)
- [Device MQTT](../microservices/device/V3Migration/#device-mqtt)
- [Device ONVIF Camera](../microservices/device/V3Migration/#device-onvif-camera)
- [Device USB Camera](../microservices/device/V3Migration/#device-usb-camera)

### Customized Environment Overrides

If you have custom [environment overrides](../microservices/configuration/CommonEnvironmentVariables/#environment-overrides) for configuration impacted by the V3 changes you will also need to migrate your overrides to use the new name or value depending on what has changed. Refer to the links above and/or below for details for migration of common and/or the service specific configuration to determine if your overrides require migrating.

!!! note
    When using the Configuration Provider, the environment overrides for common configuration are applied to the **core-common-config-bootstrapper** service. They no longer work when applied to the individual services as the common configuration setting no longer exist in the private configuration.

## Custom Compose File

The compose files for V3 have many changes from their V2 counter parts. If you have customized a V2 compose file to add additional services and/or add or modify configuration overrides,  it is highly recommended that you start with the appropriate V3 compose file and re-add your customizations. It is very likely that the sections for your additional services will need to be migrated to have the proper environment overrides. Best approach is to use one of the V3 service sections that closest matches your service  as a template.

The latest V3 compose files can be found here: [Compose Files](https://github.com/edgexfoundry/edgex-compose/tree/{{version}})

### Compose Builder

If the additional service(s) in your custom compose file are EdgeX released device or app services, it is highly recommended that you use the Compose Builder to regenerate your custom compose file. 

The latest V3 Compose Builder can be found here: [Compose Builder Readme](https://github.com/edgexfoundry/edgex-compose/tree/{{version}}/compose-builder/README.md) 

## Command Line Options

The following command-line options and corresponding environment variables have be renamed for consistency

-  `-c/--confdir`  is replaced by `-cd/--configDir`
    - `EDGEX_CONF_DIR` environment variable is replaced by `EDGEX_CONFIG_DIR`
-  `-f/--file`  is replaced by `-cf/--configFile` 
    - `EDGEX_CONFIG_FILE` has not changed
-  `-cp/ --configProvider` has not changed
  -  `EDGEX_CONFIGURATION_PROVIDER` environment variable is replaced by `EDGEX_CONFIG_PROVIDER`


If your solution uses any of the renamed options or environment variables you will need to make the appropriate changes to use the new names.

See [Command Line Options](../microservices/configuration/CommonCommandLineOptions/#config-provider) page for more details on the above options and the [Command Line Overrides](../microservices/configuration/CommonEnvironmentVariables/#command-line-overrides) section for more details on the above environment variables

## Database

There currently is no migration path for the data stored in the database. If possible, the database should be cleared prior to starting V3 EdgeX. This will allow the database to be V3 compliant from the start. See [Clearing Redis Database](#clearing-redis-database) section below for details on how to clear the Redis database.

The following sections describe what you need to be aware for the different services that create data in the database.

### Core Data

The Event/Reading data stored by Core Data is considered transient and of little value once it has become old. The V3 versions of these data collections have minimal changes from their V2 counter parts. 

#### API Change
- Add Event
    To identify which device service generating the new event, POST endpoint is now changed from `/event/{profileName}/{deviceName}/{sourceName}` to `/event/{serviceName}/{profileName}/{deviceName}/{sourceName}`

See [Core Data API Reference](../api/core/Ch-APICoreData) for complete details.
#### Reading

 There are no changes to the V3 Reading from that in V2

#### Event

The field that has changed in V3 is the `apiVersion` which is now set to `v3`.

### Core Metadata

Most of the data stored by Core Metadata will be recreated when the V3 versions of the Device Services start-up. The statically declared devices will automatically be created and device discovery will find and add existing devices. Any device profiles, devices, provision watchers created manually via the V2 REST APIs will have to be recreated using the V3 REST API. Any manually-applied `AdministrativeState` settings will also need to be re-applied.

#### API Change
- Add/ Update/ Get device
    - Remove `LastConnected`, `LastReported` and `UpdateLastConnected` from device model
    - Updated ProtocolProperties to have typed value

- Add/ Update/ Get deviceprofile
    - Added `optional` field in ResourceProperties
    - Updated the data type of `mask`, `shift`, `scale`, `base`, `maximum` and `minimum` from `string` to `number` in ResourceProperties

- Get UOM 
    - Changed the response format from TOML to YAML

- Add/ Get/ Update ProvisionWatcher
    - Allowed empty string profile name when adding or updating the ProvisionWatcher
    - The ProvisionWatcher DTO is restructured by moving the Device related fields into a new object field, `DiscoveredDevice`; such as `profileName`, Device `adminState`, and `autoEvents`.
    - Added a new properties field in the `DiscoveredDevice` object to allow any additional or customized data.
    - ProvisionWatcher contains its own `adminState` now. The Device `adminState` is moved into the `DiscoveredDevice` object.

See [Core Metadata API Reference](../api/core/Ch-APICoreMetadata) for complete details.

### Core Command
#### API Change
- Get Command
    - Updated `ds-pushevent` and `ds-returnevent` to use bool value, `true` or `false`, instead of `yes` or `no`

See [Core Command API Reference](../api/core/Ch-APICoreCommand) for complete details.

### Support Notifications

Any `Subscriptions` created via the V2 REST API will have to be recreated using the V3 REST API. The `Notification` and `Transmission`collections will be empty until new notifications are sent using EdgeX V3 

### Support Scheduler
#### API Change
- Added `authmethod` to support-scheduler actions DTO, which indicates how to authenticate the outbound URL. Use `NONE` when running in non-secure mode and `JWT` when running in secure mode.

See [Support Scheduler API Reference](../api/support/Ch-APISupportScheduler) for complete details.

The statically declared `Interval` and `IntervalAction` will be created automatically. Any `Interval` and/or `IntervalAction` created via the V2 REST API will have to be recreated using the V3 REST API. If you have created a custom configuration with additional statically declared `Interval`s and `IntervalActions` see the [Configuration File](#configuration-file) section under [Customized Configuration](#customized-configuration) below.

### Application Services

Application services use the database only when the [Store and Forward](../microservices/application/AdvancedTopics/#store-and-forward) capability is enabled. If you do not use this capability you can skip this section. This data collection only has data when that data could not be exported. It is recommended not to upgrade to V3 while the Store and Forward data collection is not empty or you are certain the data is no longer needed. You can determine if the Store and Forward data collection is empty by setting the Application Service's log level to `DEBUG`  and look for the following message which is logged every `RetryInterval`:

!!! example
    ```
    msg=" 0 stored data items found for retrying"
    ```
!!! note
    The `RetryInterval` is in the `app-services` section of [common configuration](../microservices/configuration/CommonConfiguration). Changing it there will apply to all Application Services that have the [Store and Forward](../microservices/application/AdvancedTopics/#store-and-forward) capability enabled.

### Clearing Redis Database

#### Docker

When running EdgeX in Docker the simplest way to clear the database is to remove the `db-data` volume after stopping the V2 EdgeX services. 

```console
docker-compose -f <compose-file> down
docker volume rm $(docker volume ls -q | grep db-data)
```

Now when the V3 EdgeX services are started the database will be cleared of the old v2 data.

#### Snaps

Because there are no tools to migrate EdgeX configuration and database, it's not possible to update the edgexfoundry snap from a V2 version to a V3 version. You must remove the V2 snap first, and then install a V3 version of the snap (available from the 3.0 track in the Snap Store). This will result in starting fresh with EdgeX V3 and all V2 data removed.

#### Local

If you are running EdgeX locally, i.e. not in Docker or snaps and in **non-secure** mode you can use the Redis CLI to clear the database. The CLI would have been installed when you installed Redis locally. Run the following command to clear the database:

```
redis-cli FLUSHDB
```

This will not work if running EdgeX in running in secure mode since you will not have the random generated Redis password unless you created an Admin password when you installed Redis.

## Custom Device Service

If you have custom Device Services they will need to be migrated to the V3 version of the Device SDK.  See [Device Service V3 Migration Guide](../microservices/device/V3Migration) for complete details.

## Custom Device Profile

If you have custom V2 Device Profile(s) for one of the EdgeX Device Services they will need to be migrated to the V3 version of Device Profiles.  See [Device Service V3 Migration Guide](../microservices/device/V3Migration#device-profiles) for complete details.

## Custom Pre-Defined Device

If you have custom V2 Pre-Defined Device(s) for one of the EdgeX Device Services they will need to be migrated to the V3 version of Pre-Defined Devices.  See [Device Service V3 Migration Guide](../microservices/device/V2Migration/#pre-defined-devices) for complete details.

## Custom Applications Service

 If you have custom Application Services they will need to be migrated to the V3 version of the App Functions SDK. See [Application Services V3 Migration Guide](../microservices/application/V3Migration) for complete details.

## Security

If you have an add-on services running in secure mode you will need to use the new names of the environment variables in EdgeX V3. See [Security Services V3 Migration Guide](../security/V3Migration) for more details.

### API Gateway configuration

The API gateway has changed in EdgeX V3. See [Security Services V3 Migration Guide](../security/V3Migration) for more details.

### Authenticated REST APIs

When security is enable,  all V3 EdgeX services REST APIs require a JWT authorization token. See [Security Services V3 Migration Guide](../security/V3Migration) for more details.

## eKuiper

### Rules

#### Rest Action

##### None Secure Mode

If running EdgeX in none secure mode and you have rules with `rest` action that reference an EdgeX service the endpoint API version will need to be changed from v2 to V3

!!! example - "Example migration of `rest` action with EdgeX endpoint"
    **V2:**
    ```json
    "actions": [
        {
          "rest": {
            "url": "http://edgex-core-command:59882/api/v2/device/name/Random-Integer-Device/Int64",       
            ...
          }
        }
      ]
    ```
​    **V3:**
    ```json
    "actions": [
        {
          "rest": {
            "url": "http://edgex-core-command:59882/api/v3/device/name/Random-Integer-Device/Int64",       
            ...
          }
        }
      ]
    ```

##### Secure Mode

If running EdgeX in secure mode and  you have rules with `rest` action that reference an EdgeX Core Command you will need to convert the rule to use Command via External MQTT. See [eKuiper documentation here](https://github.com/lf-edge/ekuiper/blob/master/docs/en_US/edgex/edgex_rule_engine_command.md#option-2-use-messaging) for more details. This is due to the new microservice authorization on all EdgeX services' endpoints requiring a JWT token which eKuiper doesn't have.

!!! note
    This approach requires an external MQTT broker to send the command requests. The default EdgeX compose files do not include a MQTT Broker. This broker is supposed to be external to EdgeX. 
