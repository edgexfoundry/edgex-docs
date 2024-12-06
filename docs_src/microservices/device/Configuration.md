---
title: Device Service - Configuration
---

# Device Service - Configuration

Please refer to the general [Common Configuration documentation](../configuration/CommonConfiguration.md) for configuration properties common to all services.

!!! edgey - "EdgeX 3.0"
    **UpdateLastConnected** is removed in EdgeX 3.0.

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 the `MessageQueue` configuration has been move to `MessageBus` in [Common Configuration](../configuration/CommonConfiguration.md#common-configuration-properties)


!!! edgey "EdgeX 3.1"
    New in EdgeX 3.1 is URI for files which allows the private configuration file to be pulled from a remote location via a URI rather than from the local file system. See [Config File Command-line](../configuration/CommonCommandLineOptions.md#config-file) section for more details.

!!! note
    The `*` on the configuration section names below denoted that these sections are pulled from the device service common configuration thus are not in the individual device service's private configuration file.

=== "Writable"
|Property|Default Value|Description|
|---|---|---|
||Writable properties can be set and will dynamically take effect without service restart|
|LogLevel|INFO|log entry [severity level](https://en.wikipedia.org/wiki/Syslog#Severity_level).  Log entries not of the default level or higher are ignored. |
=== "Writable.Reading*"
|Property|Default Value|Description|
|---|---|---|
|ReadingUnits|true|Indicate the units of measure for the Value in the Reading, set to `false` to not include units in the Reading. |
=== "Writable.Telemetry*"
|Property|<div style="width:300px">Default Value</div>|Description|
|---|---|---|
|||See `Writable.Telemetry` at [Common Configuration](../../configuration/CommonConfiguration/#configuration-properties) for the Telemetry configuration common to all services |
|Metrics|     |Service metrics that the device service collects. Boolean value indicates if reporting of the metric is enabled. Common and custom metrics are also included.|
||`EventsSent` = false     |Enable/disable reporting of the built-in **EventsSent** metric|
||`ReadingsSent` = false     |Enable/disable reporting of the built-in **ReadingsSent** metric|
||`LastConnected` = false     |Enable/disable reporting of the built-in **LastConnected** metric|
||`<CustomMetric>` = false    |Enable/disable reporting of custom device service's custom metric. See [Custom Device Service Metrics](../device/sdk/details/CustomConfiguration.md) for more details.|
|Tags|`<empty>`|List of arbitrary service level tags to included with every metric that is reported.  |
=== "Clients.core-metadata*"
|Property|Default Value|Description|
|---|---|---|
|Protocol|http| The protocol to use when building a URI to the service endpoint|
|Host|localhost| The host name or IP address where the service is hosted |
|Port|59881| The port exposed by the target service|
=== "Device*"
|Property|Default Value|Description|
|---|---|---|
|||Properties that determine how the device service communicates with a device|
|DataTransform|true|Controls whether transformations are applied to numeric readings|
|MaxCmdOps|128|Maximum number of resources in a device command (hence, readings in an event)|
|MaxCmdResultLen|256|Maximum JSON string length for command results|
|ProfilesDir|'./res/profiles'|If set, directory or index URI containing profile definition files to upload to core-metadata. See [URI for Device Service Files](#uris-for-device-service-files) for more information on URI index files. Also may be in device service private config, so it can be overridden with environment variable|
|DevicesDir|'./res/devices'|If set, directory or index URI containing device definition files to upload to core-metadata. See [URI for Device Service Files](#uris-for-device-service-files) for more information on URI index files. Also may be in device service private config, so it can be overridden with environment variable|
|ProvisionWatchersDir|''|If set, directory or index URI containing provision watcher definition files to upload to core-metadata (service specific when needed). See [URI for Device Service Files](#uris-for-device-service-files) for more information on URI index files.|
|EnableAsyncReadings| true| Enables/Disables the Device Service ability to handle async readings |
|AsyncBufferSize| 16| Size of the buffer for async readings|
|AllowedFails|0|If set, number of consecutive failures to access a device after which the service will set the device's OperationalState to DOWN|
|DeviceDownTimeout|0|If set, an interval in seconds after which a device which has been automatically set DOWN will be re-tried to see if it is accessible again|
|Discovery/Enabled|false|Controls whether device discovery is enabled|
|Discovery/Interval|30s|Interval between automatic discovery runs. Zero means do not run discovery automatically|
=== "MaxEventSize*"
|Property|Default Value|Description|    
|---|---|---|
|MaxEventSize|0|maximum event size in kilobytes sent to Core Data or MessageBus. 0 represents default to system max.|

## URIs for Device Service Files

!!! edgey "EdgeX 3.1"
    Support for URIs for Devices, Profiles, and Provision Watchers is new in EdgeX 3.1.

When loading device definitions, device profiles, and provision watchers from a URI, the directory field (ie `DevicesDir`, `ProfilesDir`, `ProvisionWatchersDir`) loads an index file instead of a folder name.
The contents of the index file will specify the individual files to load by URI by appending the filenames to the URI as shown in the example below.
Any authentication specified in the original URI will be used in subsequent URIs. See the [URI for Files](../general/index.md#uri-for-files) section for more details.

!!! example "Example Device Dir loaded from URI in service configuration"
```yaml
...
ProfilesDir = "./res/profiles"
DevicesDir = "http://example.com/devices/index.json"
ProvisionWatchersDir = "./res/provisionwatchers"
...
```

#### Device Definition URI Example
For device definitions, the index file contains the list of references to device files that contain one or more devices.

!!! example "Example Device Index File at `http://example.com/devices/index.json` and resulting URIs"
    ```json
    [
        "device1.yaml", "device2.yaml"
    ]
    which results in the following URIs:
    http://example.com/devices/device1.yaml
    http://example.com/devices/device2.yaml
    ```

#### Device Profile and Provision Watchers URI Example
For device profiles and provision watchers, the index file contains a dictionary of key-value pairs that map the name of the profile or provision watcher to its file.
The name is mapped so that the resources are only loaded from a URI if a device profile or provision watcher by that name has not been loaded yet.

!!! example "Example Device Profile Index File at `http://example.com/profiles/index.json` and resulting URIs"
    ```json
    {
        "Simple-Device": "Simple-Driver.yaml",
        "Simple-Device2": "Simple-Driver2.yml"
    }
    which results in the following URIs:
    http://example.com/profiles/Simple-Driver.yaml
    http://example.com/profiles/Simple-Driver2.yml
    ```

## Custom Configuration

Device services can have custom configuration in one of two ways. See the table below for details.

=== "Driver"
    `Driver` - The Driver section used for simple custom settings and is accessed via the SDK's DriverConfigs() API. The DriverConfigs API returns a `map[string] string` containing the contents on the `Driver` section of the `configuration.yaml` file.
    
    ```yaml
    Driver:
      MySetting: "My Value"
    ```
=== "Custom Structured Configuration"
    For Go Device Services see [Go Custom Structured Configuration](../device/sdk/details/CustomConfiguration.md#go-device-service-sdk-custom-structured-configuration) for more details.
    

    For C Device Service see [C Custom Structured Configuration](../device/sdk/details/CustomConfiguration.md#c-device-service-sdk-custom-structured-configuration) for more details.

## Secrets

#### Configuration

!!! edgey "Edgex 3.0"
    For EdgeX 3.0 the **SecretStore** configuration has been removed from each service's configuration files. It has default values which can be overridden with environment variables. See the [SecretStore Overrides](../configuration/CommonEnvironmentVariables.md#secretstore-configuration-overrides) section for more details.

All instances of Device Services running in secure mode require a `SecretStore` to be created for the service by the Security Services. See [Configuring Add-on Service](../../../security/Ch-Configuring-Add-On-Services) for details on configuring a `SecretStore` to be created for the Device Service. With the use of `MQTT` as the default EdgeX MessageBus all Device Services need the `postgres` known secret added to their `SecretStore` so they can connect to the Secure EdgeX MessageBus. See the [Secure MessageBus](../../../security/Ch-Secure-MessageBus) documentation for more details.

Each Device Service also has detailed configuration to enable connection to it's exclusive `SecretStore`

#### Storing Secrets

##### Secure Mode

When running an Device Service in secure mode, secrets can be stored in the SecretStore by making an HTTP `POST` call to the `/api/{{api_version}}/secret` API route on the Device Service. The secret data POSTed is stored to the service's secure`SecretStore` . Once a secret is stored, only the service that added the secret will be able to retrieve it.  See the [Secret API Reference](../../api/devices/Ch-APIDeviceSDK.md#swagger) for more details and example.

##### Insecure Mode

When running in insecure mode, the secrets are stored and retrieved from the *Writable.InsecureSecrets* section of the service's configuration.yaml file. Insecure secrets and their paths can be configured as below.

!!! example "Example - InsecureSecrets Configuration"
    ```yaml
    Writable:
      InsecureSecrets:    
        DB:
         SecretName: "postgres"
         SecretData:
           username: "postgres"
           password: "postgres"
        MQTT:
          SecretName: "credentials"
        SecretData:
           username: "mqtt-user"
           password: "mqtt-password"
    ```

#### Retrieving Secrets

Device Services retrieve secrets from their `SecretStore` using the SDK API.  See [Retrieving Secrets](../device/sdk/details/Secrets.md#retrieving-secrets) for more details using the Go SDK. 
