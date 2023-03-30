# V2 Migration Guide

## Custom Application Services

### Configuration

The migration of any Application Service's configuration starts with migrating configuration common to all EdgeX services. See the [V2 Migration of Common Configuration](../../configuration/V2MigrationCommonConfig) section for details. The remainder of this section focuses on configuration specific to Application Services.

#### SecretStoreExclusive

The `SecretStoreExclusive` section has been removed in EdgeX 2.0. With EdgeX 2.0 all SecretStores are exclusive, so the existing `SecretStore` section is all that is required. Services requiring `known secrets` such as `redisdb` must inform the `Security SecretStore Setup` service (via environment variables) that the application service requires the secret added to its SecretStore. See the [Configuring Add-on Services](../../../security/Ch-Configuring-Add-On-Services) section for more details.

#### Clients

The client used for the version validation check has changed to being from Core Metadata, rather than Core Data. This is because Core Data is now optional when persistence isn't required since all Device Services publish directly to the EdgeX MessageBus. The configuration for Core Metadata is the only `Clients` entry required, all other (see below) are optional based on use case needs. 

!!! note 
    The port numbers for all EdgeX services have changed which must be reflected in the `Clients` configuration. Please see the [Default Service Ports](../../../general/ServicePorts) section for complete list of the new port assignments. 

!!! example "Example - Core Metadata client configuration"
    ```toml
      [Clients]
        [Clients.core-metadata]
        Protocol = "http"
        Host = "localhost"
        Port = 59881
    ```

!!! example "Example - All available clients configured with new port numbers"
    ```toml
      [Clients]
        # Used for version check on start-up
        # Also used for DeviceService, DeviceProfile and Device clients
        [Clients.core-metadata]
        Protocol = "http"
        Host = "localhost"
        Port = 59881
        
        # Used for Event client which is used by PushToCoreData function
        [Clients.core-data]
        Protocol = "http"
        Host = "localhost"
        Port = 59880
        
        # Used for Command client
        [Clients.core-command]
        Protocol = "http"
        Host = "localhost"
        Port = 59882
        
        # Used for Notification and Subscription clients
        [Clients.support-notifications]
        Protocol = "http"
        Host = "localhost"
        Port = 59860
    ```

#### Trigger

The `Trigger` section (previously named `Binding`) has been restructured with `EdgexMessageBus` (previously named `MessageBus`) and `ExternalMqtt` (previously named `MqttBroker` ) moved under it. The `SubscribeTopics` (previously named `SubscribeTopic`) has been moved under the `EdgexMessageBus.SubscribeHost` and `ExternalMqtt` sections. The `PublishTopic` has been moved under the `EdgexMessageBus.PublishHost` and `ExternalMqtt` sections.

##### EdgeX MessageBus

If your Application Service is using the EdgeX MessageBus trigger, you can then simply copy the complete `Trigger` configuration from the example below and tweak it as needed. 

!!! example "Example - EdgeX MessageBus trigger configuration"

    ```toml
    [Trigger]
    Type="edgex-messagebus"
      [Trigger.EdgexMessageBus]
      Type = "redis"
        [Trigger.EdgexMessageBus.SubscribeHost]
        Host = "localhost"
        Port = 6379
        Protocol = "redis"
        SubscribeTopics="edgex/events/#"
        [Trigger.EdgexMessageBus.PublishHost]
        Host = "localhost"
        Port = 6379
        Protocol = "redis"
        PublishTopic="example"
        [Trigger.EdgexMessageBus.Optional]
        AuthMode = "usernamepassword"  # required for redis messagebus (secure or insecure).
        SecretName = "redisdb"
    ```

From the above example you can see the improved structure and the following changes:

- Default `EdgexMessageBus` type has changed from `ZeroMQ` to `Redis`.
- Type value for `Redis` has changed from `redistreams` to `redis`. This is because the implementation no longer uses Redis Streams. It now uses Redis Pub/Sub.
- `SubscribeTopics` is now plural since it now accepts a comma separated list of topics. The default value uses a multi-level topic with a wild card. This is because Core Data and Device Services now publish to a multi-level topics which have`edgex/events` as their base. This allows Application Services to filter by topic rather then receive the data and then filter it out via a pipeline filter function. See the [Filter By Topics](../Triggers/#filter-by-topics) section for more details.
- The EdgeX MessageBus using Redis is a Secure MessageBus, thus the addition of the `AuthMode` and `SecretName` settings which allow the credentials to be pulled from the service's SecretStore. See the [Secure MessageBus](../../../security/Ch-Secure-MessageBus) secure for more details.

##### External MQTT

If your Application service is using the **External MQTT** trigger do the following:

1. Move your existing `MqttBroker` configuration under the `Trigger` section (renaming it to `ExternalMqtt`)
2. Move your `SubscribeTopic` (renaming it to `SubscribeTopics`) under the `ExternalMqtt` section.
3. Move your `PublishTopic` under the `ExternalMqtt` section.

!!! example "Example - External MQTT trigger configuration"

    ```toml
    [Trigger]
    Type="external-mqtt"
      [Trigger.ExternalMqtt]
      Url = "tcp://broker.hivemq.com:1883"
      SubscribeTopics = "edgex-trigger"
      PublishTopic = "edgex-trigger-response"
      ClientId = "app-my-service"
      ConnectTimeout = "30s"
      AutoReconnect = false
      KeepAlive = 60
      QoS = 0
      Retain = false
      SkipCertVerify = false
      SecretPath = ""
      AuthMode = "none"
    ```

##### HTTP

The HTTP trigger configuration has not changed beyond the renaming of `Binding` to `Trigger`.

!!! example "Example - HTTP trigger configuration"

    ```toml
    [Trigger]
    Type="http"
    ```

### Code

#### Dependencies

You first need to update the `go.mod` file to specify `go 1.16` and the V2 versions of the App Functions SDK and any EdgeX go-mods directly used by your service. Note the extra `/v2` for the modules.

!!! example "Example go.mod for V2"

    ```go
    module <your service>
    
    go 1.16
    
    require (
    	github.com/edgexfoundry/app-functions-sdk-go/v2 v2.0.0
    	github.com/edgexfoundry/go-mod-core-contracts/v2 v2.0.0
    )
    ```

Once that is complete then the import statements for these dependencies must be updated to include the `/v2` in the path. 

!!! example "Example import statements for V2"

    ```go
    import (
    	...
        
    	"github.com/edgexfoundry/app-functions-sdk-go/v2/pkg/interfaces"
    	"github.com/edgexfoundry/go-mod-core-contracts/v2/dtos"
    )
    ```

#### New APIs

Next changes you will encounter in your code are that the `AppFunctionsSDK` and `Context` structs have been abstracted into the new `ApplicationService` and `AppFunctionContext` APIs. See the [Application Service API](../ApplicationServiceAPI) and [App Function Context API](../AppFunctionContextAPI) sections for complete details on these new APIs. The following sections cover migrating your code for these new APIs.

#### main()

The following changes to your `main()` function will be necessary.

##### Create and Initialize

Your `main()` will change to use a factory function to create and initialize the Application Service instance, rather than create instance of `AppFunctionsSDK` and call `Initialize()` 

!!! example "Example - Create Application Service instance"

    ```go
        const serviceKey = "app-myservice"
        ...
    
        service, ok := pkg.NewAppService(serviceKey)
        if !ok {
            os.Exit(-1)
        }
    ```

!!! example "Example - Create Application Service instance with Target Type specified"

    ```go
        const serviceKey = "app-myservice"
        ...
    
        service, ok := pkg.NewAppServiceWithTargetType(serviceKey, &[]byte{})
        if !ok {
            os.Exit(-1)
        }
    ```

Since the factory function logs all errors, all you need to do is exit if it returns `false`. 

##### Logging Client

The `Logging` client is now accessible from the `service.LoggingClient()` API. 

!!! note "New extended Logging Client API"
    The Logging Client API now has `formatted` versions of all the logging APIs, which are `Infof`, `Debugf`, `Tracef`, `Warnf `and `Errorf`. If your code uses `fmt.Sprintf` to format your log messages then it can now be simplified by using these new APIs.

##### Application Settings

The access functions for retrieving the service's custom Application Settings (`ApplicationSettings`, `GetAppSettingStrings`,  and `GetAppSetting` ) have not changed. An improved capability to have structured custom configuration has been added. See the [Structure Custom Configuration](../AdvancedTopics/#structure-custom-configuration) section for more details.

##### Functions Pipeline

Setting the  Functions Pipeline has not changed, but the name of some built in functions have changed and new ones have been added. See the [Built-In Pipeline Functions](../BuiltIn) section for more details.

!!! example "Example - Setting Functions Pipeline"

    ```go
    if err := service.SetFunctionsPipeline(
    	transforms.NewFilterFor(deviceNames).FilterByDeviceName,
    	transforms.NewConversion().TransformToXML,
    	transforms.NewHTTPSender(exportUrl, "application/xml", false).HTTPPost,
    ); err != nil {
    	lc.Errorf("SetFunctionsPipeline returned error: %s", err.Error())
    	os.Exit(-1)
    }
    ```

##### MakeItRun

The `MakeItRun` API has not changed.

!!! example "Example - Call to MakeItRun"

    ```go
    err = service.MakeItRun()
    if err != nil {
    	lc.Errorf("MakeItRun returned error: %s", err.Error())
    	os.Exit(-1)
    }
    ```

#### Custom Pipeline Functions

##### Pipeline Function signature

The major change to custom Pipeline Functions for EdgeX 2.0 is the new function signature which drives all the other changes.

!!! example "Example - New Pipeline Function signature"

    ```go
    type AppFunction = func(ctx AppFunctionContext, data interface{}) (bool, interface{})
    ```

This function signature passes in an instance of the new AppFunctionContext API for the context and now has only a single `data` instance for the function to operate on.

##### Return Values

The definitions for the Pipeline Function return values have not changed.

##### Data

The `data` passed in is set either to a data object for the function to process or nil.  Check the length of the incoming data is no longer needed. The default `TargetType` for pipeline functions has changed from `models.Event` to `dtos.Event`. The data type should be validated to ensure the data received is the type the function expects to process.

!!! example - "Example - Validating data before processing"

    ```go
    	if data == nil {
    		return false, errors.New("No Data Received")
    	}
    	
    	event, ok := data.(dtos.Event)
        if !ok {
            return false, fmt.Errorf("data type received is not an Event")
        }
    ```

!!! note
    The `models.Event` still exists, but is for internal use only for those services that persist the `Events` to a database.

##### Logging Client

The `Logging` client is now accessible from the `ctx.LoggingClient()` API. 

##### Clients

The available clients have changed with a few additions and `ValueDescriptorClient` has been removed. See the [Context Clients](../AppFunctionContextAPI/#clients) section for complete list of available clients.

##### ResponseData

The `SetResponseData` and `ResponseData` APIs replace the previous `Complete` function and direct access to the `OutputData` field.

##### ResponseContentType

The `SetResponseContentType` and `ResponseContentType` APIs replace the previous direct access to the `ResponseContentType` field.

##### RetryData

The `SetRetryData` API replaces the `SetRetryData` function and direct access to the `RetryData` field.

##### MarkAsPushed

The `MarkAsPushed` capability has been removed

##### PushToCore

The `PushToCore` API replaces the `PushToCoreData` function. The API signature has changed. See the [PushToCore](../AppFunctionContextAPI/#pushtocore) section for more details.

##### New Capabilities

Some new capabilities have been added to the new `AppFunctionContext` API. See the [App Function Context](../AppFunctionContextAPI) API section for complete details.

## App Service Configurable Profiles

Custom profiles used with App Service Configurable are configuration files. These follow the same migration above for custom  [Application Service configuration](#configuration), except for the Configurable Functions Pipeline items.  The following are the changes for the Configurable Functions Pipeline:

1. `FilterByValueDescriptor` changed to `FilterByResourceName`. See the [FilterByResourceName](../AppServiceConfigurable/#filterbyresourcename) section for details.
2. `TransformToXML` and `TransformToJSON` have been collapsed into `Transform` with additional parameters. See the [Transform](../AppServiceConfigurable/#transform) section for more details.
3. `CompressWithGZIP` and `CompressWithZLIB` have been collapsed into `Compress` with additional parameters. See the [Compress](../AppServiceConfigurable/#compress) section for more details.
4. `EncryptWithAES` has been changed to `Encrypt` with additional parameters. See the [Encrypt](../AppServiceConfigurable/#encrypt) section for more details.
5. `BatchByCount`, `BatchByTime` and `BatchByTimeAndCount` have been collapsed into `Batch` with additional parameters. See the [Batch](../AppServiceConfigurable/#batch) section for more details.
6. `SetOutputData` has been renamed to `SetResponseData`. See the [SetResponseData](../AppServiceConfigurable/#setresponsedata) section for more details.
7. `PushToCore` parameters have changed. See the [PushToCore](../AppServiceConfigurable/#pushtocore) section for more details.
8. `HTTPPost`, `HTTPPostJSON`, `HTTPPostXML`, `HTTPPut`, `HTTPPutJSON` and `HTTPPutXML` have been collapsed into `HTTPExport` with additional parameters. See the [HTTPExport](../AppServiceConfigurable/#httpexport) section for more details.
9. `MQTTSecretSend` has been renamed to `MQTTExport` with additional parameters. See the [MQTTExport](../AppServiceConfigurable/#mqttexport) section for more details.
10. `MarkAsPushed` has been removed. The mark as push capability has been removed from Core Data, which this depended on.
11. `MQTTSend` has been removed. This has been replaced by `MQTTExport`. See the [MQTTExport](../AppServiceConfigurable/#mqttexport) section for more details.
12. `FilterByProfileName` and `FilterBySourceName` have been added. See the [FilterByProfileName](../AppServiceConfigurable/#filterbyprofilename) and  [FilterBySourceName](../AppServiceConfigurable/#filterbysourcename) sections for more details.
13. Ability to define multiple instances of the same Configurable Pipeline Function has been added. See the [Multiple Instances of Function](../AppServiceConfigurable/#multiple-instances-of-function) section for more details.

