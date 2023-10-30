# V3 Device Service Migration Guide

## All Device Services

This section is specific to changes made that impact only and **all device services**.

See [Top Level V3 Migration Guide](../../../V3TopLevelMigration) for details applicable to all EdgeX Services.

### Device Files

1. Change device definition file in the Device Service to YAML format.
2. Remove `LastConnected` and `LastReported` configs.
3. ProtocolProperties now supports typed values.

    !!! example "ProtocolProperty with typed values"
    
        ```yaml
        protocols:
          other:
            Address: simple01
            Port: 300
        ```

4. The boolean field `notify` has been removed as it is never used.
5. An extendable field `properties` has been added to Device. See [Metadata Dictionary](../core/metadata/details/DeviceProfile.md) and point to **Device tab** for complete details.
6. Added `tags` field to Device for event level tagging. See [Metadata Dictionary](../core/metadata/details/DeviceProfile.md) and point to **Device tab** for complete details.

### Device Profile Files

1. Add `optional` field in ResourceProperties to allow any additional or customized data.
2. Change the data type of `mask`, `shift`, `scale`, `base`, `offset`, `maximum` and `minimum` from string to number in ResourceProperties.

    > NOTE: When the device profile is in JSON format, please ensure that the values for `mask` are specified in decimal, as the JSON number type does not support hexadecimal. YAML does not have this limitation.

3. Added `tags` field in DeviceResource for reading level tagging. See [Metadata Dictionary](../core/metadata/details/DeviceProfile.md) and point to **DeviceResource tab** for complete details.
4. Added `tags` field in DeviceCommand for event level tagging. See [Metadata Dictionary](../core/metadata/details/DeviceProfile.md) and point to **DeviceCommand tab** for complete details.

### Provision Watcher files

1. The ProvisionWatcher DTO is restructured by moving the Device related fields into a new object field, `DiscoveredDevice`; such as `profileName`, Device `adminState`, and `autoEvents`.
2. Allow to define additional or customized data by utilizing the `properties` field in the `DiscoveredDevice` object.
3. ProvisionWatcher contains its own `adminState` now. The Device `adminState` is moved into the `DiscoveredDevice` object.
4. ProvisionWatcher can now be added during device service startup by loading the definition files from the `ProvisionWatchersDir` configuration.

    !!! example "Example Configuration"
    
        ```yaml
        Device:
            ProvisionWatchersDir: ./res/provisionwatchers
        ```

5. ProvisionWatcher definition file is in YAML format.

    !!! example "Pre-defined ProvisionWatcher"

        ```yaml
        name: Simple-Provision-Watcher
        serviceName: device-simple
        labels:
          - simple
        identifiers:
          Address: simple[0-9]+
          Port: 3[0-9]{2}
        blockingIdentifiers:
          Port:
            - 397
            - 398
            - 399
        adminState: UNLOCKED
        discoveredDevice:
          profileName: Simple-Device
          adminState: UNLOCKED
          autoEvents:
            - interval: 15s
              sourceName: SwitchButton
          properties:
            testPropertyA: weather
            testPropertyB: meter
        ```

6. An extendable field `properties` has been added to ProvisionWatcher. See [Metadata Dictionary](../core/metadata/details/DeviceProfile.md) and point to **DiscoveredDevice tab** for complete details.

## Custom Device Services

This section is specific to changes made that impact existing **custom device services**.

See [Top Level V3 Migration Guide](../../../V3TopLevelMigration) for details applicable to all EdgeX services and [All Device Services](#all-device-services) section above for details applicable to all EdgeX device services.  

### Dependencies
You first need to update the `go.mod` file to specify `go 1.20` and the V3 versions of the Device SDK and any EdgeX go-mods directly used by your service. Note the extra `/v3` for the modules.

!!! example "Example go.mod for V3"

    ```go
    module <your service>
    
    go 1.20
    
    require (
    	github.com/edgexfoundry/device-sdk-go/v3 v3.0.0
    	github.com/edgexfoundry/go-mod-core-contracts/v3 v3.0.0
        ...
    )
    ```

Once that is complete then the import statements for these dependencies must be updated to include the `/v3` in the path.

!!! example "Example import statements for V3"

    ```go
    import (
    	...
        
    	"github.com/edgexfoundry/device-sdk-go/v3/pkg/models"
    	"github.com/edgexfoundry/go-mod-core-contracts/v3/common"
    )
    ```

### Go Device Services
1. The type of ProtocolProperties is now `map[string]any` instead of `map[string]string` to support typed values.
2. Configuration file changes:
    - The configuration file is now in YAML format, and the default file name is configuration.yaml.
    - Add `ProvisionWatchersDir` configuration to support adding provision watchers during device service startup.
    - Remove `UpdateLastConnected` from configuration.
    - Remove `UseMessageBus` from configuration. MessageBus is always enabled in 3.0 for sending events and receiving system events for callbacks.
    - Remove Common config settings from configuration. See [V3 Migration of Common Configuration](../../configuration/V3MigrationCommonConfig) for details.
    - Internal topics no longer configurable. See [V3 Migration of Common Configuration](../../configuration/V3MigrationCommonConfig#messagebus) for details.
3. ProtocolDriver interface changes:
    - Add `Start` method. The `Start` method is called after the device service is completely initialized, allowing the service to run startup tasks.
    - Add `Discover` method. The `Discover` method triggers protocol specific device discovery, asynchronously writes the results to the channel which is passed to the implementation via `ProtocolDriver.Initialize()`. The results may be added to the device service based on a set of acceptance criteria (i.e. Provision Watchers).
    - Add `ValidateDevice` method. The `ValidateDevice` method triggers device's protocol properties validation, returns error if validation failed and the incoming device will not be added into EdgeX.
    - Update the `Initialize` method signature to pass DeviceServiceSDK interface as parameter.
4. Remove global variable `ds *DeviceService` in service package. Instead, the [DeviceServiceSDK interface](sdk/SDK-Go-API.md) introduced in Levski release is passed to ProtocolDriver as the only parameter in Initialize method so that developer can still access, mock and test with it.
5. SDK API changes:
    - Add [`Run`](sdk/SDK-Go-API.md#run) method.
    - Add [`PatchDevice`](sdk/SDK-Go-API.md#patchdevice) method.
    - Add [`DeviceExistsForName`](sdk/SDK-Go-API.md#deviceexistsforname) method.
    - Add [`AsyncValuesChannel`](sdk/SDK-Go-API.md#asyncvalueschannel) method.
    - Add [`DiscoveredDeviceChannel`](sdk/SDK-Go-API.md#discovereddevicechannel) method.
    - Refactor [`UpdateDeviceOperatingState`](sdk/SDK-Go-API.md#updatedeviceoperatingstate) method to accept a `OperatingState` value.
    - Rename `AsyncReadings` to [`AsyncReadingsEnabled`](sdk/SDK-Go-API.md#asyncreadingsenabled).
    - Rename `DeviceDiscovery` to [`DeviceDiscoveryEnabled`](sdk/SDK-Go-API.md#devicediscoveryenabled).
    - Rename `GetLoggingClient` to [`LoggingClient`](sdk/SDK-Go-API.md#loggingclient).
    - Rename `GetSecretProvider` to [`SecretProvider`](sdk/SDK-Go-API.md#secretprovider).
    - Rename `GetMetricsManager` to [`MetricsManager`](sdk/SDK-Go-API.md#metricsmanager).
    - Remove `Stop` method as it should only be called by SDK.
    - Remove `SetDeviceOperatingState` method.
    - Remove the `Service` function that returns the device service SDK instance.
    - Remove the `RunningService` function that returns the Device Service instance.
6. Add additional level in event publish topic for device service name. The topic is now `<PublishTopicPrefix>/<device-service-name>/<device-profile-name>/<device-name>/<source-name>`
7. The following REST callback endpoints are removed and replaced by the [System Events](../core/metadata/details/DeviceSystemEvents.md) mechanism:
    - `/validate/device`
    - `/callback/service`
    - `/callback/watcher`
    - `/callback/watcher/name/{name}`
    - `/callback/profile`
    - `/callback/device`
    - `/callback/device/name/{name}`
8. Remove old metrics collection and REST `/metrics` endpoint.
9. Remove ZeroMQ MessageBus capability.

### C Device Services

1. There is a new dependency on IOTech's C Utilities which should be satisfied
by installing the relevant package. Previous versions built the utilities into
the SDK library. Installation instructions for the utility package may be found
in the [C SDK repository](https://github.com/edgexfoundry/device-sdk-c/blob/v3.0.1/README.IOT.md).

2. Configuration file changes:
    - The configuration file is now in YAML format, and the default file name is configuration.yaml.
    - Remove `UseMessageBus` from configuration. MessageBus is always enabled in 3.0 for sending events and receiving system events for callbacks.
    - Internal topics no longer configurable. See [V3 Migration of Common Configuration](../../configuration/V3MigrationCommonConfig#messagebus) for details.

3. The `type` field in both `devsdk_resource_t` and `devsdk_device_resources`
is now an `iot_typecode_t` rather than a pointer to one. Additionally the
`type` field in `edgex_resourceoperation` is an `iot_typecode_t`.

4. The `edgex_propertytype` enum and the functions for obtaining one from
`iot_data_t` have been removed. Instead, first consult the `type` field of
an `iot_typecode_t`. This is an instance of the `iot_data_type_t` enumeration,
the enumerands of which are similar to the EdgeX types, except that there are
some additional values (not used in the C SDK) such as Vectors and Pointers,
and there is a singular Array type. The type of array elements is held in the
`element_type` field of the `iot_typecode_t`.

5. Binary data is now supported directly in the utilities, so instead of
allocating an array of uint8, the `iot_data_alloc_binary` function is available.

6. Add additional level in event publish topic for device service name. The topic is now `<PublishTopicPrefix>/<device-service-name>/<device-profile-name>/<device-name>/<source-name>`

7. The following REST callback endpoints are removed and replaced by the [System Events](../core/metadata/details/DeviceSystemEvents.md) mechanism:
    - `/validate/device`
    - `/callback/service`
    - `/callback/watcher`
    - `/callback/watcher/name/{name}`
    - `/callback/profile`
    - `/callback/device`
    - `/callback/device/name/{name}`

8. Remove old metrics collection and REST `/metrics` endpoint.

## Supported Device Services

### Device MQTT

This section is specific to changes made only to **Device MQTT**. 

See [Top Level V3 Migration Guide](../../../V3TopLevelMigration) for details applicable to all EdgeX services and [All Device Services](#all-device-services) section above for details applicable to all EdgeX device services. 

#### Metadata in MQTT Topics

For EdgeX 3.0, Device MQTT now only supports the multi-level topics. Publishing the metadata and command/reading data wrapped in a JSON object is no longer supported. The published payload is now always only the reading data. 

!!! example - "Example V2 JSON object wrapper no longer used"

    ```json
    {
       "name": "<device-name>",
       "cmd": "<source-name>",
       "<source-name>": Base64 encoded JSON containing
    		{
              "<resource1>" : value1,
              "<resource2>" : value2,
              ...
            }
    }
    ```

Your MQTT based device(s) must be migrated to use this new approach. See below for more details.

##### Async Data

A sync data is published to the `incoming/data/{device-name}/{source-name}` topic where:

- **device-name** is the name of the device sending the reading(s)

- **source-name** is the command or resource name for the published data
    - If the **source-name** matches a command name the published data must be JSON object with the resource names specified in the command as field names.

        !!! example - "Example async published command data"
            Topic=`incoming/data/MQTT-test-device/allValues`
            ```json
            {
              "randfloat32" : 3.32,
              "randfloat64" : 5.64,
              "message" : "Hi World"
            }
            ```

    - If the **source-name** only matches a resource name the published data can either be just the reading value for the resource or a JSON object with the resource name as the field name.

        !!! example - "Example async published resource data"
            Topic=`incoming/data/MQTT-test-device/randfloat32`
            ```json
            5.67

            or
            
            {
              "randfloat32" : 5.67
            }
            ```

##### Commanding

Commands send to the device will be sent on the`command/{device-name}/{command-name}/{method}/{uuid}` topic where:

- **device-name** is the name of the device which will receive the command
- **command-name** is the name of the command being set to the device
- **method** is the type of command, `get` or `set`
- **uuid** is a unique identifier for the command request

###### Set Command

If the command method is a `set`, the published payload contains a JSON object with the resource names and the values to set those resources.

!!! example - "Example Data for Set Command"
    ```json
    {
       "randfloat32" : 3.32,
       "randfloat64" : 5.64
    }
    ```

The device is expected to publish an empty response to the topic `command/response/{uuid}` where **uuid** is the unique identifier sent in command request topic. 

###### Get Command

If the command method is a `get`, the published payload is empty and the device is expected to publish a response to the topic `command/response/{uuid}` where **uuid** is the unique identifier sent in command request topic. The published payload contains a JSON object with the resource names for the specified command and their values.

!!! example - "Example Response Data for Get Command"
    ```json
    {
       "randfloat32" : 3.32,
       "randfloat64" : 5.64,
       "message" : "Hi World"
    }
    ```

### Device ONVIF Camera

This section is specific to changes made only to **Device ONVIF Camera**.

See [Top Level V3 Migration Guide](../../../V3TopLevelMigration) for details applicable to all EdgeX services and [All Device Services](#all-device-services) section above for details applicable to all EdgeX device services.

#### Configuration

- Helper scripts have been deprecated in favor of using the REST APIs. 
See [here for camera credential management](../supported/device-onvif-camera/Walkthrough/deployment#manage-devices), and see [here for configuring `DiscoverySubnets`](../supported/device-onvif-camera/supplementary-info/auto-discovery#discoverysubnets).

#### Device Profile

Some commands have been renamed for clarity. See the latest [Swagger API Documentation](../supported/device-onvif-camera/swagger) for full details.

| EdgeX v2 Command Name         | EdgeX v3 Command Name         |
|-------------------------------|-------------------------------|
| Profiles                      | MediaProfiles                 |
| Scopes                        | DiscoveryScopes               |
| AddScopes                     | AddDiscoveryScopes            |
| RemoveScopes                  | RemoveDiscoveryScopes         |
| GetNodes                      | PTZNodes                      |
| GetNode                       | PTZNode                       |
| GetConfigurations             | PTZConfigurations             |
| Configuration                 | PTZConfiguration              |
| GetConfigurationOptions       | PTZConfigurationOptions       |
| AbsoluteMove                  | PTZAbsoluteMove               |
| RelativeMove                  | PTZRelativeMove               |
| ContinuousMove                | PTZContinuousMove             |
| Stop                          | PTZStop                       |
| GetStatus                     | PTZStatus                     |
| SetPreset                     | PTZPreset                     |
| GetPresets                    | PTZPresets                    |
| GotoPreset                    | PTZGotoPreset                 |
| RemovePreset                  | PTZRemovePreset               |
| GotoHomePosition              | PTZGotoHomePosition           |
| SetHomePosition               | PTZHomePosition               |
| SendAuxiliaryCommand          | PTZSendAuxiliaryCommand       |
| GetAnalyticsConfigurations    | Media2AnalyticsConfigurations |
| AddConfiguration              | Media2AddConfiguration        |
| RemoveConfiguration           | Media2RemoveConfiguration     |
| GetSupportedRules             | AnalyticsSupportedRules       |
| Rules                         | AnalyticsRules                |
| CreateRules                   | AnalyticsCreateRules          |
| DeleteRules                   | AnalyticsDeleteRules          |
| GetRuleOptions                | AnalyticsRuleOptions          |
| SetSystemFactoryDefault       | SystemFactoryDefault          |
| GetVideoEncoderConfigurations | VideoEncoderConfigurations    |
| GetEventProperties            | EventProperties               |
| OnvifCameraEvent              | CameraEvent                   |
| GetSupportedAnalyticsModules  | SupportedAnalyticsModules     |
| GetAnalyticsModuleOptions     | AnalyticsModuleOptions        |


- Get `Snapshot` command requires a media profile token to be sent in the jsonObject parameter, similar to `StreamUri` command.
- `Capabilities` command's `Category` field format is now an array of strings instead of a single string. This now matches the spec.
- Device Command `VideoStream` has been removed. It was never tested, and the same functionality can be done through the use of `MediaProfiles` and `StreamUri` calls.

### Device USB Camera

This section is specific to changes made only to **Device USB Camera**

See [Top Level V3 Migration Guide](../../../V3TopLevelMigration) for details applicable to all EdgeX services and [All Device Services](#all-device-services) section above for details applicable to all EdgeX device services.

#### RTSP Authentication

All USB camera rtsp streams need authentication by default. To properly configure credentials for the stream refer [here](services/device-usb-camera/supplementary-info/advanced-options.md#rtsp-authentication). This will require the building of custom images.  
To see how to use this feature once the service is deployed, see [here](services/device-usb-camera/walkthrough/deployment.md#add-credentials-for-the-rtsp-stream).
