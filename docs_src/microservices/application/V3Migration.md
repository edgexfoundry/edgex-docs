---
title: App Services - V3 Migration Guide
---

# Application Services - V3 Migration Guide

## Configuration

The migration of any Application Service's configuration starts with migrating configuration common to all EdgeX services. See the [V3 Migration of Common Configuration](../../configuration/V3MigrationCommonConfig) section for details including the change from **TOML** format to **YAML** format for the configuration file. The remainder of this section focuses on configuration specific to Application Services.

### Common Configuration Removed

Any configuration that is common to all EdgeX services or all EdgeX Application Services needs to be removed from custom application service's private configuration. 

- See [Common Service Configuration](../../configuration/CommonConfiguration/) section for details about configuration that is common to all Edgex services. 
- See [Application Service Configuration](Configuration.md) section for details about configuration that is common to all EdgeX Application Services.

!!! note
    With this change, any custom application service must be run with either the `-cp/--configProvider` flag or the `-cc/--commonConfig` flag in order for the service to receive the common configuration that has been removed from its private configuration. See [Config Provider](../../configuration/CommonCommandLineOptions/#config-provider) and [Common Config](../../configuration/CommonCommandLineOptions/#common-config) sections for more details on these flags.

### MessageBus

The EdgeX MessageBus configuration has been moved out of the Trigger configuration and most values are placed in the common configuration. The only values remaining in the application service's private configuration are:

- `Disabled` - Used to disable the use of the EdgeX MessageBus when not using metrics and not using `edgex-messagebus` Trigger type. Value need to be present so that it can be overridden with environment variable.
- `Optional.ClientId` - Unique name needed for when MQTT or NATS are used as the MessageBus implementation.

!!! example - "Example Application Service specific MessageBus section for 3.0"
   ```yaml
   MessageBus:
     Disabled: false  # Set to true if not using metrics and not using `edgex-messagebus` Trigger type
     Optional:
       ClientId: "<service-key>"
   ```

### Trigger

#### edgex-messagebus changes

As noted above the EdgeX MessageBus configuration has been removed from the **Trigger** configuration. In addition, the `SubscribeTopics` and `PublishTopic` settings have been move to the top level of the **Trigger** configuration. Most application services can simply use the default trigger configuration from application service common configuration.

!!! example - "Example application service Trigger configuration - From Common Configuration "
    ```yaml
    Trigger:
      Type: "edgex-messagebus"
      SubscribeTopics: "events/#" # Base topic is prepended to this topic when using edgex-messagebus
    ```

!!! example - "Example local application service Trigger configuration - **None**"
```yaml
# Using default Trigger config from common config
```

Some application services may need to publish results back to the EdgeX MessageBus. In this case the `PublishTopic` will remain in the service private configuration.

!!! example - "Example local application service Trigger configuration - **PublishTopic**"
    ```yaml
    Trigger:
      # Default value for SubscribeTopics is also set in common config
      PublishTopic: "<my-topic>"  # Base topic is prepended to this topic when using edgex-messagebus
    ```

!!! note
    In EdgeX 3.0 Application services, the base topic in MessageBus common configuration is prepended to the configured `SubscribeTopics` and `PublishTopic` values. The default base topic is `edgex`; thus,  all topics start with `edgex/`

#### edgex-messagebus Trigger Migration

- If the common Trigger configuration is what your service needs
    1. Remove your **Trigger** configuration completely

- If your service publishes back to the EdgeX MessageBus
    1. Move your `PublishTopic` to top level in your **Trigger** configuration
    2. Remove `edgex/` prefix if used
    3. Remove remaining **Trigger** configuration

- If your service uses filter by topic
    1. Move `SubscribeTopics` to top level in your **Trigger** configuration
    2. Remove `edgex/` prefix from each topic if used
    3. Replace `#` between levels with `+` . See [Multi-level topics and wildcards](../../general/messagebus/#multi-level-topics-and-wildcards) section for more details
    4. Remove remaining **Trigger** configuration

#### External MQTT changes

The **External MQTT** trigger configuration remains under **Trigger** configuration, but the `SubscribeTopics` and `PublishTopic` setting have been moved to the top level of the **Trigger** configuration. 

!!! example "Example - External MQTT trigger configuration"
    ```yaml
    Trigger:
      Type: "external-mqtt"
      SubscribeTopics: "external-request/#"
      PublishTopic: "" # optional if publishing response back to the the External MQTT Broker
      ExternalMqtt:
        Url: "tcp://broker.hivemq.com:1883" #  fully qualified URL to connect to the MQTT broker
        ClientId: "app-my-service"
        ConnectTimeout: "30s" 
        AutoReconnect: true
        KeepAlive: 10 # Seconds (must be 2 or greater)
        QoS: 0 # Quality of Service 0 (At most once), 1 (At least once) or 2 (Exactly once)
        Retain: true
        SkipCertVerify: false
        SecretName: "mqtt-trigger" 
        AuthMode: "none"
    ```

####  external-mqtt **Trigger** Migration

1. Move your `SubscribeTopics` and `PublishTopic` top level of the **Trigger** configuration

#### HTTP Changes

The HTTP trigger configuration has not changed for EdgeX 3.0

### Writable Pipeline

See [Pipeline Configuration](#pipeline-configuration) section below for changes to the Writable Pipeline configuration

## Custom Application Service 

### Code

#### Dependencies

You first need to update the `go.mod` file to specify `go 1.20` and the v3 versions of the App Functions SDK and any EdgeX go-mods directly used by your service. 

!!! example "Example go.mod for V3"

    ```go
    module <your service>
    
    go 1.20
    
    require (
    	github.com/edgexfoundry/app-functions-sdk-go/v3 v3.0.0
    	github.com/edgexfoundry/go-mod-core-contracts/v3 v3.0.0
    )
    ```

Once that is complete then the import statements for these dependencies must be updated to include the `/v3` in the path. 

!!! example "Example import statements for V3"

    ```go
    import (
    	...
        
    	"github.com/edgexfoundry/app-functions-sdk-go/v3/pkg/interfaces"
    	"github.com/edgexfoundry/go-mod-core-contracts/v3/dtos"
    )
    ```

#### API Changes

##### ApplicationService API

The `ApplicationService` API has the following changes:

1.  `SetFunctionsPipeline` has been removed. Use `SetDefaultFunctionsPipeline ` instead
2. `MakeItRun` has been renamed to `Run`
3. `MakeItStop` has been renamed to `Stop`
4. `GetSecret` has been removed. Use `SecretProvider().GetSecret`
5. `StoreSecret` has been removed. Use `SecretProvider().StoreSecret`
6. `LoadConfigurablePipeline` has been removed. Use `LoadConfigurableFunctionPipelines`
7. `CommandClient` `Get` API's `dsPushEvent` and `dsReturnEvent` parameters changed to be type `bool`

See [Application Service API](sdk/api/ApplicationServiceAPI.md) section for completed details on this API, including some new capabilities.

##### AppFunctionContext API

The `AppFunctionContext ` API has the following changes:

1. Deprecated `PushToCore` has been removed. Use [WrapIntoEvent](sdk/api/BuiltInPipelineFunctions.md#wrap-into-event) function and publishing to the EdgeX MessageBus instead. See [Trigger.PublishTopic](sdk/details/Triggers.md#publishtopic) or [Publish](sdk/api/ApplicationServiceAPI.md#publish) sections for more details on publishing data back to the EdgeX MessageBus.
2. `GetSecret` has been removed. Use `SecretProvider().GetSecret`
3. `StoreSecret` has been removed. Use `SecretProvider().StoreSecret`
4. `SecretsLastUpdated` has been removed. Use `SecretProvider().SecretsLastUpdated`
5. `CommandClient` `Get` API's `dsPushEvent` and `dsReturnEvent` parameters changed to be type `bool`

#### Pipeline Functions

- **AESProtection**
    - `NewAESProtection` signature has changes. 
        - `secretName ` parameter renamed to`secretValueKey` 
        - `secretPath` parameter renamed to `secretName ` 
    - `Encrypt` pipeline function now require a `*AESProtection` for the receiver
    - `NewAESProtection` now returns a `*AESProtection`
- **Compression**
    - All `Compression` pipeline functions now require a `*Compression` for the receiver
    - `NewCompression` now returns a `*Compression`
- **Conversion**
    - All `Conversion` pipeline functions now require a `*Conversion` for the receiver
    - `NewConversion` now returns a `*Conversion`
- **CoreData**- Removed
    - The deprecated `PushToCoreData ` function has been removed. Use [WrapIntoEvent](sdk/api/BuiltInPipelineFunctions.md#wrap-into-event) function and publishing to the EdgeX MessageBus instead. See [Trigger.PublishTopic](sdk/details/Triggers.md#publishtopic) or [Publish](sdk/api/ApplicationServiceAPI.md#publish) sections for more details on publishing data back to the EdgeX MessageBus.
- **Encryption** - Removed
    - The deprecated `EncryptWithAES` function has been removed, use `AESProtection.Encrypt` instead. See [AES Protection](sdk/api/BuiltInPipelineFunctions.md#aesprotection) for more details
- **Filter**
    - All `Filter` pipeline functions now requires a `*Filter` for the receiver
    - `NewFilterFor` and `NewFilterOut` now return a `*Filter`
- **HTTPSender**
    - `NewHTTPSenderWithSecretHeader` signature has changed
        - `secretName ` parameter renamed to`secretValueKey` 
        - `secretPath` parameter renamed to `secretName ` 
- **JSONLogic**
    - `Evaluate` pipeline function now requires a `*JSONLogic` for the receiver
    - `NewJSONLogic` now returns a `*JSONLogic`
- **MQTTSecretSender**
    - `MQTTSecretConfig ` has changed
        - `SecretPath` field renamed to `SecretName ` 
- **ResponseData**
    - `SetResponseData` pipeline function now requires a `*ResponseData` for the receiver
    - `NewResponseData` now returns a `*ResponseData`
- **Tags**
    - Factory function `NewGenericTags` has been removed and replaced with new version of `NewTags` which takes ` map[string]interface{}` for the `tags` parameter.
    - `NewTags` now returns a `*Tags`

## App Service Configurable

### Profiles

- `PushToCore` profile has been removed. Use [WrapIntoEvent](sdk/api/BuiltInPipelineFunctions.md#wrap-into-event) function and publishing to the EdgeX MessageBus instead. See [Trigger.PublishTopic](sdk/details/Triggers.md#publishtopic) or [Publish](sdk/api/ApplicationServiceAPI.md#publish) sections for more details on publishing data back to the EdgeX MessageBus.

### Custom Profiles

Custom profiles for App Service Configurable must be migrated in a similar fashion to the configuration for custom application services.  All configuration that is common to all EdgeX services or all EdgeX Application Services needs to be removed from custom profiles. See [Common Service Configuration](../../configuration/CommonConfiguration/) section for details about configuration that is common to all Edgex services. See [Application Service Configuration](Configuration.md) section for details about configuration that is common to all EdgeX Application Services. Use the App Service Configurable provided profiles as examples of what configuration is left after removing the common configuration.

### Pipeline Configuration

- **Writable.Pipeline.TargetType** has change from a bool to a string with valid values or `raw`, `event` or `metric`
- Topic wild cards have changed to conform 100% with MQTT scheme. The `#` between level has be replaced with `+` . See [Multi-level topics and wildcards](../../general/messagebus/#multi-level-topics-and-wildcards) for more details.
- **HTTPExport** function configuration
    - Parameter `SecretName`  renamed to be  `SecretValueKey`  
    - Parameter `SecretPath` renamed to be `SecretName` 
- **Encrypt** function configuration 
    - Parameter `SecretName`  renamed to be  `SecretValueKey`  
    - Parameter `SecretPath` renamed to be `SecretName` 

### Environment Variable Overrides

Environment variable overrides must be adjusted appropriately for the above changes. Remove any overrides that apply to common configuration.
