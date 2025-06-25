---
title: Core Metadata - Configuration
---

# Core Metadata - Configuration

Please refer to the general [Common Configuration documentation](../../configuration/CommonConfiguration.md) for configuration settings common to all services.
Below are only the additional settings and sections that are specific to Core Metadata.

!!! edgey - "EdgeX 3.0"
    **Notifications** configuration is removed in EdgeX 3.0. Metadata will leverage [Device System Events](details/DeviceSystemEvents.md) to replace the original device change notifications.

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 the `MessageQueue` configuration has been moved to `MessageBus` in [Common Configuration](../../configuration/CommonConfiguration.md#common-configuration-properties).

=== "Writable"
|Property|Default Value|Description|
|---|---|---|
|||entries in the Writable section of the configuration can be changed on the fly while the service is running if the service is running with the `-cp/--configProvider` flag|
|LogLevel|INFO|log entry [severity level](https://en.wikipedia.org/wiki/Syslog#Severity_level).  Log entries not of the default level or higher are ignored. |
|MaxDevices|0|Indicates the maximum capacity of devices. If `MaxDevices` exceeds 0, the Core Metadata service will check whether the capacity exceed the limitation when adding or updating the device. |
|MaxResources|0|Indicates the maximum capacity of resources that can be used by devices. If `MaxResources` exceeds 0, the Core Metadata service will check whether the capacity exceeds the limitation when adding or updating the device.<br/> For example, the MaxResources is 5, and two devices use the same device profile which has 5 resources, when you post these two devices, the first device is successful to add, but the second device fails due to the resource limit. |
=== "Writable.Telemetry"
|Property|Default Value|Description|
|---|---|---|
|||See `Writable.Telemetry` at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties) for the Telemetry configuration common to all services |
|Metrics| `<TBD>` |Service metrics that Core Metadata collects. Boolean value indicates if reporting of the metric is enabled.|
|Tags|`<empty>`|List of arbitrary Core Metadata service level tags to included with every metric that is reported. |
=== "Writable.ProfileChange"
|Property|Default Value|Description|
|---|---|---|
|StrictDeviceProfileChanges|false|Whether to allow device profile modifications, set to `true` to reject all modifications which might impact the existing events and readings. Thus, the changes like `manufacture`, `isHidden`, or `description` can still be made.|
|StrictDeviceProfileDeletes|false|Whether to allow device profile deletionsm set to `true` to reject all deletions.|
=== "Writable.UoM"
|Property|Default Value|Description|
|---|---|---|
|Validation|false|Whether to enable units of measure validation, set to `true` to validate all device profile `units` against the list of units of measure by core metadata.|
=== "Service"
|Property|Default Value|Description|
|---|---|---|
||| Unique settings for Core Metadata. The common settings can be found at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)
| Port | 59881|Micro service port number|
|StartupMsg |This is the EdgeX Core Metadata Microservice|Message logged when service completes bootstrap start-up|
=== "UoM"
|Property|Default Value|Description|
|---|---|---|
|UoMFile|'./res/uom.yaml'|path to the location of units of measure configuration|
=== "Database"
|Property|Default Value|Description|
|---|---|---|
||| Unique settings for Core Metadata. The common settings can be found at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)
|Name|metadata|Database or document store name |
=== "MessageBus.Optional"
|Property|Default Value|Description|
|---|---|---|
||| Unique settings for Core Metadata. The common settings can be found at [Common Configuration](../../../configuration/CommonConfiguration/#configuration-properties)
|ClientId|core-metadata|Id used when connecting to MQTT or NATS base MessageBus |

## Units of Measure

Core metadata will read unit of measure configuration (see configuration example below) located in `UoM.UoMFile` during startup.
The specified configuration may be a local configuration file or the URI of the configuration. See the [URI for Files](../../general/index.md#uri-for-files) section for more details.

!!! edgey "EdgeX 3.1"
    Support for loading the `UoM.UoMFile` configuration via URI is new in EdgeX 3.1. 

!!! example - "Sample unit of measure configuration"
    ```yaml
    Source: reference to source for all UoM if not specified below
    Units:
      temperature:
        Source: www.weather.com
        Values:
          - C
          - F
          - K
      weights:
        Source: www.usa.gov/federal-agencies/weights-and-measures-division
        Values:
          - lbs
          - ounces
          - kilos
          - grams
    ```

When validation is turned on (`Writable.UoM.Validation` is set to `true`),
all device profile `units` (in device resource, device properties) will be validated against the list of units of measure by core metadata.

In other words, when a device profile is created or updated via the core metadata API, the units specified in the device resource's `units` field
will be checked against the valid list of UoM provided via core metadata configuration.

If the `units` value matches any one of the configuration units of measure, then the device resource is considered valid - allowing the create or update operation to continue.
If the `units` value does not match any one of the configuration units of measure, then the device profile or device resource operation (create or update) is rejected (error code 500 is returned) and an appropriate error message is returned in the response to the caller of the core metadata API.

!!! Note
    The `units` field on a profile is and shall remain optional.  If the `units` field is not specified in the device profile, then it is assumed that the device resource does not have well-defined units of measure.  In other words, core metadata will not fail a profile with no `units` field specified on a device resource.

### V3 Configuration Migration Guide
- Removed `RequireMessageBus`
- UoMFile value changed to point to YAML file instead of TOML file

See [Common Configuration Reference](../../../configuration/V3MigrationCommonConfig/) for complete details on common configuration changes.