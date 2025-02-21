---
title: App SDK - Application Service API
---

# App Functions SDK - Application Service API

The `ApplicationService` API is the central API for creating an EdgeX Application Service.

The new `ApplicationService` API is as follows:

```go
type AppFunction = func(appCxt AppFunctionContext, data interface{}) (bool, interface{})

type FunctionPipeline struct {
	Id         string
	Transforms []AppFunction
	Topic      string
	Hash       string
}

type ApplicationService interface {
	ApplicationSettings() map[string]string
	GetAppSetting(setting string) (string, error)
	GetAppSettingStrings(setting string) ([]string, error)
	LoadCustomConfig(config UpdatableConfig, sectionName string) error
	ListenForCustomConfigChanges(configToWatch interface{}, sectionName string, changedCallback func(interface{})) error
    SetDefaultFunctionsPipeline(transforms ...AppFunction) error
	AddFunctionsPipelineForTopics(id string, topics []string, transforms ...AppFunction) error
	LoadConfigurableFunctionPipelines() (map[string]FunctionPipeline, error)
    RemoveAllFunctionPipelines()
    Run() error
	Stop()
    SecretProvider() interfaces.SecretProvider
	LoggingClient() logger.LoggingClient
	EventClient() interfaces.EventClient
	ReadingClient() interfaces.ReadingClient
    CommandClient() interfaces.CommandClient
	NotificationClient() interfaces.NotificationClient
	SubscriptionClient() interfaces.SubscriptionClient
	DeviceServiceClient() interfaces.DeviceServiceClient
	DeviceProfileClient() interfaces.DeviceProfileClient
	DeviceClient() interfaces.DeviceClient
	RegistryClient() registry.Client
	MetricsManager() bootstrapInterfaces.MetricsManager
	AddBackgroundPublisher(capacity int) (BackgroundPublisher, error)
	AddBackgroundPublisherWithTopic(capacity int, topic string) (BackgroundPublisher, error)
	BuildContext(correlationId string, contentType string) AppFunctionContext
    AddRoute(route string, handler func(http.ResponseWriter, *http.Request), methods ...string) error
    AddCustomRoute(route string, authentication Authentication, handler echo.HandlerFunc, methods ...string) error
  	AppContext() context.Context
    RequestTimeout() time.Duration
	RegisterCustomTriggerFactory(name string, factory func(TriggerConfig) (Trigger, error)) error
    RegisterCustomStoreFactory(name string, factory func(cfg DatabaseInfo, cred config.Credentials) (StoreClient, error)) error
    Publish(data any) error
    PublishWithTopic(topic string, data any) error
}
```

## Factory Functions

The App Functions SDK provides two factory functions for creating an `ApplicationService`

### NewAppService

`NewAppService(serviceKey string) (interfaces.ApplicationService, bool)`

This factory function returns an `interfaces.ApplicationService` using the default Target Type of `dtos.Event`  and initializes the service. The second `bool` return parameter will be `true` if successfully initialized, otherwise it will be `false` when error(s) occurred during initialization. All error(s) are logged so the caller just needs to call `os.Exit(-1)` if `false` is returned.

!!! example "Example - NewAppService"

    ```go
    const serviceKey = "app-myservice"
    ...
    
    service, ok := pkg.NewAppService(serviceKey)
    if !ok {
        os.Exit(-1)
    }
    ```

### NewAppServiceWithTargetType

`NewAppServiceWithTargetType(serviceKey string, targetType interface{}) (interfaces.ApplicationService, bool)`

This factory function returns an `interfaces.ApplicationService` using the passed in Target Type and initializes the service. The second `bool` return parameter will be `true` if successfully initialized, otherwise it will be `false` when error(s) occurred during initialization. All error(s) are logged so the caller just needs to call `os.Exit(-1)` if `false` is returned.

See the [Target Type](../details/TargetType.md) advanced topic for more details.

!!! example "Example - NewAppServiceWithTargetType"
    ``` go
    const serviceKey = "app-my-service"
    ...
    
    service, ok := pkg.NewAppServiceWithTargetType(serviceKey, &[]byte{})
    if !ok {
        os.Exit(-1)
    }
    ```

## Custom Configuration APIs

The following `ApplicationService` APIs allow your service to access their custom configuration from the configuration file and/or Configuration Provider. See the [Custom Configuration](../details/CustomConfiguration.md) advanced topic for more details.

### ApplicationSettings

`ApplicationSettings() map[string]string`

This API returns the complete key/value map of custom settings

!!! example "Example - ApplicationSettings"

    ```yaml
    ApplicationSettings:
      Greeting: "Hello World"
    ```
    
    ```go
    appSettings := service.ApplicationSettings()
    greeting := appSettings["Greeting"]
    service.LoggingClient.Info(greeting)
    ```

### GetAppSetting

`GetAppSetting(setting string) (string, error)`

This API is a convenience API that returns a single setting from the `[ApplicationSetting]`
 section of the service configuration. An error is returned if the specified setting is not found.

!!! example "Example - GetAppSetting"

    ```yaml
    ApplicationSettings:
     Greeting: "Hello World"
    ```
    
    ```go
    greeting, err := service.GetAppSetting["Greeting"]
    if err != nil {
        ...
    }
    service.LoggingClient.Info(greeting)
    ```

### GetAppSettingStrings

`GetAppSettingStrings(setting string) ([]string, error)`

This API is a convenience API that parses the string value for the specified custom application setting as a comma separated list. It returns the list of strings. An error is returned if the specified setting is not found.

!!! example "Example - GetAppSettingStrings"

    ```yaml
    ApplicationSettings:
     Greetings: "Hello World, Welcome World, Hi World"
    ```
    
    ```go
    greetings, err := service.GetAppSettingStrings["Greetings"]
    if err != nil {
        ...
    }
    for _, greeting := range greetings {
      service.LoggingClient.Info(greeting)
    }
    ```

### LoadCustomConfig

`LoadCustomConfig(config UpdatableConfig, sectionName string) error`

This API loads the service's Structured Custom Configuration from local file or the Configuration Provider (if enabled). The Configuration Provider will also be seeded with the custom configuration if service is using the Configuration Provider. The `UpdateFromRaw` API (`UpdatableConfig` interface) will be called on the custom configuration when the configuration is loaded from the Configuration Provider. The custom config must implement the `UpdatableConfig` interface.

!!! example "Example - LoadCustomConfig"

    ```yaml
    AppCustom: # Can be any name you choose
      ResourceNames: "Boolean, Int32, Uint32, Float32, Binary"
      SomeValue: 123
      SomeService:
        Host: "localhost"
        Port: 9080
        Protocol: "http"
    ```
    
    ```go
    type ServiceConfig struct {
    	AppCustom AppCustomConfig
    }
    
    type AppCustomConfig struct {
    	ResourceNames string
    	SomeValue     int
    	SomeService   HostInfo
    }
    
    func (c *ServiceConfig) UpdateFromRaw(rawConfig interface{}) bool {
    	configuration, ok := rawConfig.(*ServiceConfig)
    	if !ok {
    		return false //errors.New("unable to cast raw config to type 'ServiceConfig'")
    	}
    
    	*c = *configuration
    
    	return true
    }
    
    ...
    
    serviceConfig := &ServiceConfig{}
    err := service.LoadCustomConfig(serviceConfig, "AppCustom")
    if err != nil {
      ...
    }
    ```

See the [App Service Template](https://github.com/edgexfoundry/app-functions-sdk-go/blob/{{edgexversion}}/app-service-template/main.go#L73-L97) for a complete example of using Structured Custom Configuration.

### ListenForCustomConfigChanges

`ListenForCustomConfigChanges(configToWatch interface{}, sectionName string, changedCallback func(interface{})) error`

This API starts a listener on the Configuration Provider for changes to the specified section of the custom configuration. When changes are received from the Configuration Provider the provided `changedCallback` function is called with the updated section of configuration. The service must then implement the code to copy the updates into it's copy of the configuration and respond to the updates if needed.

!!! example "Example - ListenForCustomConfigChanges"

    ```yaml
    AppCustom: # Can be any name you choose
      ResourceNames: "Boolean, Int32, Uint32, Float32, Binary"
      SomeValue: 123
      SomeService:
        Host: "localhost"
        Port: 9080
        Protocol: "http"
    ```
    
    ```go
    ...
    
    err := service.ListenForCustomConfigChanges(&serviceConfig.AppCustom, "AppCustom", ProcessConfigUpdates)
    if err != nil {
    	logger.Errorf("unable to watch custom writable configuration: %s", err.Error())
    }
    
    ...
    
    func (app *myApp) ProcessConfigUpdates(rawWritableConfig interface{}) {
    	updated, ok := rawWritableConfig.(*config.AppCustomConfig)
    	if !ok {
    		...
    		return
    	}
    
    	previous := app.serviceConfig.AppCustom
    	app.serviceConfig.AppCustom = *updated
    
    	if reflect.DeepEqual(previous, updated) {
    		logger.Info("No changes detected")
    		return
    	}
    
    	if previous.SomeValue != updated.SomeValue {
    		logger.Infof("AppCustom.SomeValue changed to: %d", updated.SomeValue)
    	}
    	if previous.ResourceNames != updated.ResourceNames {
    		logger.Infof("AppCustom.ResourceNames changed to: %s", updated.ResourceNames)
    	}
    	if !reflect.DeepEqual(previous.SomeService, updated.SomeService) {
    		logger.Infof("AppCustom.SomeService changed to: %v", updated.SomeService)
    	}
    }
    
    ```

See the [App Service Template](https://github.com/edgexfoundry/app-functions-sdk-go/blob/{{edgexversion}}/app-service-template/main.go#L73-L97) for a complete example of using Structured Custom Configuration.

## Function Pipeline APIs

The following `ApplicationService` APIs allow your service to set the Functions Pipeline and start and stop the Functions Pipeline.

### AppFunction

`type AppFunction = func(appCxt AppFunctionContext, data interface{}) (bool, interface{})`

This type defines the signature that all pipeline functions must implement.

### FunctionPipeline

This type defines the struct that contains the metadata for a functions pipeline instance.

```go
type FunctionPipeline struct {
	Id         string
	Transforms []AppFunction
	Topic      string
	Hash       string
}
```

### SetDefaultFunctionsPipeline

`SetDefaultFunctionsPipeline(transforms ...AppFunction) error`

This API sets the default functions pipeline with the specified list of Application Functions.  This pipeline is executed for all messages received from the configured trigger. Note that the functions are executed in the order provided in the list.  An error is returned if the list is empty.

!!! example "Example - SetDefaultFunctionsPipeline"
    ```go
    sample := functions.NewSample()
    err = service.SetDefaultFunctionsPipeline(
        transforms.NewFilterFor(deviceNames).FilterByDeviceName,
        sample.LogEventDetails,
        sample.ConvertEventToXML,
        sample.OutputXML)
    if err != nil {
        app.lc.Errorf("SetDefaultFunctionsPipeline returned error: %s", err.Error())
        return -1
    }
    ```

### AddFunctionsPipelineForTopics

`AddFunctionsPipelineForTopics(id string, topics []string, transforms ...AppFunction) error`

This API adds a functions pipeline with the specified unique ID and list of functions (transforms) to be executed when the received topic matches one of the specified pipeline topics. See the [Pipeline Per Topic](../details/PipelinesPerTopics.md) section for more details.

!!! example "Example - AddFunctionsPipelineForTopics"
    ```go
    sample := functions.NewSample()
    err = service.AddFunctionsPipelineForTopic("Floats-Pipeline", 
                                               []string{"edgex/events/+/+/Random-Float-Device/#"},
                                               transforms.NewFilterFor(deviceNames).FilterByDeviceName,
                                               sample.LogEventDetails,
                                               sample.ConvertEventToXML,
                                               sample.OutputXML)
    if err != nil {
        ...
        return -1
    }
    ```

### LoadConfigurableFunctionPipelines

`LoadConfigurableFunctionPipelines() (map[string]FunctionPipeline, error)`

This API loads the function pipelines (default and per topic) from configuration.  An error is returned if the configuration is not valid, i.e. missing required function parameters, invalid function name, etc.

!!! note
    This API is only useful if pipeline is always defined in configuration as is with App Service Configurable.

!!! example "Example - LoadConfigurableFunctionPipelines"
    ```go
    configuredPipelines, err := service.LoadConfigurableFunctionPipelines()
    if err != nil {
        ...
        os.Exit(-1)
    }
    
    ...
    
    for _, pipeline := range configuredPipelines {
        switch pipeline.Id {
        case interfaces.DefaultPipelineId:
            if err = service.SetDefaultFunctionsPipeline(pipeline.Transforms...); err != nil {
                ...
                os.Exit(-1)
            }
        default:
            if err = service.AddFunctionsPipelineForTopic(pipeline.Id, pipeline.Topic, pipeline.Transforms...); err != nil {
                ...
                os.Exit(-1)
            }
        }
    }
    ```

### RemoveAllFunctionPipelines

`RemoveAllFunctionPipelines()`

This API removes all existing functions pipelines previously added via `SetDefaultFunctionsPipeline`, `AddFunctionsPipelineForTopics` or `LoadConfigurableFunctionPipelines`

### Run

`Run() error`

This API starts the configured trigger to allow the Functions Pipeline to execute when the trigger receives data. The internal webserver is also started. This is a long-running API which does not return until the service is stopped or Stop() is called. An error is returned if the trigger can not be created or initialized or if the internal webserver encounters an error.

!!! example "Example - Run"

    ```go
    if err := service.Run(); err != nil {
       logger.Errorf("Run returned error: %s", err.Error())
       os.exit(-1)
    }
    
    // Do any required cleanup here, if needed
    
    os.exit(0)
    ```

### Stop

`Stop()`

This API  stops the configured trigger so that the functions pipeline no longer executes. The internal webserver continues to accept requests. 
Application Services will listen for SIGTERM / SIGINT signals from the OS and stop the function pipeline in response. The pipeline can also be exited programmatically by calling sdk.Stop() on the running `ApplicationService` instance. This can be useful for cases where you want to stop a service in response to a runtime condition, e.g. receiving a "poison pill" message through its trigger.

!!! example "Example - Stop"

    ```go
    service.Stop()
    ...
    ```

## Secrets APIs

The following `ApplicationService` APIs allow your service retrieve and store secrets from/to the service's SecretStore. See the [Secrets](../details/Secrets.md) advanced topic for more details about using secrets.

### SecretProvider

`SecretProvider() interfaces.SecretProvider`

This API returns reference to the SecretProvider instance. See [Secret Provider API](../../../../security/Ch-SecretProviderApi.md) section for more details.

## Client APIs

The following `ApplicationService` APIs allow your service access the various EdgeX clients and their APIs.

### LoggingClient

`LoggingClient() logger.LoggingClient`

This API returns the LoggingClient instance which the service uses to log messages. See the [LoggingClient interface](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/logger/logger.go#L35-L61) for more details. 

!!! example "Example - LoggingClient"

    ```go
    service.LoggingClient().Info("Hello World")
    service.LoggingClient().Errorf("Some error occurred: %w", err)
    ```

### RegistryClient

`RegistryClient() registry.Client`

This API returns the Registry Client. Note the registry must have been enabled, otherwise this will return nil.
See the [Registry Client interface](https://github.com/edgexfoundry/go-mod-registry/blob/{{edgexversion}}/registry/interface.go#L23-L44) for more details. Useful if service needs to add additional health checks or needs to get endpoint of another registered service.

### EventClient

`EventClient() interfaces.EventClient`

This API returns the Event Client. Note if Core Data is not specified in the Clients configuration, this will return nil. See the [Event Client interface](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/event.go#L18-L43) for more details. Useful for adding, deleting  or querying Events.

### ReadingClient

`ReadingClient() interfaces.ReadingClient`

This API returns the Reading Client. Note if Core Data is not specified in the Clients configuration, this will return nil. See the [Reading Client interface](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/reading.go) for more details. Useful for querying Reading.

### CommandClient

`CommandClient() interfaces.CommandClient`

This API returns the Command Client. Note if Core Command is not specified in the Clients configuration, this will return nil. See the [Command Client interface](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/command.go#L17-L35) for more details. Useful for issuing commands to devices.

### NotificationClient

`NotificationClient() interfaces.NotificationClient`

This API returns the Notification Client. Note if Support Notifications is not specified in the Clients configuration, this will return nil. See the [Notification Client interface](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/notification.go#L17-L44) for more details. Useful for sending notifications.

### SubscriptionClient

`SubscriptionClient() interfaces.SubscriptionClient`

This API returns the Subscription client. Note if Support Notifications is not specified in the Clients configuration, this will return nil. See the [Subscription Client interface](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/subscription.go#L17-L35) for more details. Useful for creating notification subscriptions.

### DeviceServiceClient

`DeviceServiceClient() interfaces.DeviceServiceClient`

This API returns the Device Service Client. Note if Core Metadata is not specified in the Clients configuration, this will return nil. See the [Device Service Client interface](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/subscription.go#L17-L35) for more details. Useful for querying information about a Device Service.

### DeviceProfileClient

`DeviceProfileClient() interfaces.DeviceProfileClient`

This API returns the Device Profile Client. Note if Core Metadata is not specified in the Clients configuration, this will return nil. See the [Device Profile Client interface](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/deviceprofile.go#L17-L55) for more details. Useful for querying information about a Device Profile such as Device Resource details.

### DeviceClient

`DeviceClient() interfaces.DeviceClient`

This API returns the Device Client. Note if Core Metadata is not specified in the Clients configuration, this will return nil. See the [Device Client interface](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/device.go#L17-L44) for more details. Useful for querying list of devices for a specific Device Service or Device Profile.

## Background Publisher APIs

The following `ApplicationService` APIs allow Application Services to have background publishers. See the [Background Publishing](../details/BackgroundPublishing.md) advanced topic for more details and example.

### AddBackgroundPublisher *DEPRECATED*

`AddBackgroundPublisher(capacity int) (BackgroundPublisher, error)`

This API adds and returns a BackgroundPublisher which is used to publish asynchronously to the Edgex MessageBus. 

### AddBackgroundPublisherWithTopic *DEPRECATED*

`AddBackgroundPublisherWithTopic(capacity int, topic string) (BackgroundPublisher, error)`

This API adds and returns a BackgroundPublisher which is used to publish asynchronously to the Edgex MessageBus on the specified topic. 

### BuildContext

`BuildContext(correlationId string, contentType string) AppFunctionContext`

This API allows external callers that may need a context (e.g. background publishers) to easily create one.

## Other APIs

### AddRoute (Deprecated)

`AddRoute(route string, handler func(http.ResponseWriter, *http.Request), methods ...string) error`

This API is deprecated in favor of `AddCustomRoute()` which has an explicit parameter to indicate whether the route should require authentication.

### AddCustomRoute

`AddCustomRoute(route string, authentication Authentication, handler echo.HandlerFunc, methods ...string) error`

This API adds a custom REST route to the application service's internal webserver.  If the route is marked authenticated, it will require an EdgeX JWT when security is enabled.  A reference to the ApplicationService is added to the context that is passed to the handler, which can be retrieved using the `AppService` key. See [Custom REST Endpoints](../details/CustomRestApis.md) advanced topic for more details and example.

### AppContext

`AppContext() context.Context`

This API returns the application service context used to detect cancelled context when the service is terminating. Used by custom app service to appropriately exit any long-running functions.

### RequestTimeout

`RequestTimeout() time.Duration`

This API returns the parsed value for the `Service.RequestTimeout` configuration setting. The setting is parsed on start-up so that any error is caught then.

!!! example "Example - RequestTimeout"
    ```yaml
    Service:
    ...
      RequestTimeout: "60s"
    ...
    ```
    
    ```go
    timeout := service.RequestTimeout()
    ```

### RegisterCustomTriggerFactory

`RegisterCustomTriggerFactory(name string, factory func(TriggerConfig) (Trigger, error)) error`

This API registers a trigger factory for a custom trigger to be used. See the [Custom Triggers](../../details/Triggers.md#custom-triggers) section for more details and example.

### RegisterCustomStoreFactory

`RegisterCustomStoreFactory(name string, factory func(cfg DatabaseInfo, cred config.Credentials) (StoreClient, error)) error`

This API registers a factory to construct a custom store client for the [store & forward](../details/StoreAndForward.md) loop.

### MetricsManager

`MetricsManager() bootstrapInterfaces.MetricsManager`

This API returns the Metrics Manager used to register counter, gauge, gaugeFloat64 or timer metric types from github.com/rcrowley/go-metrics

```go
myCounterMetricName := "MyCounter"
myCounter := gometrics.NewCounter()
myTags := map[string]string{"Tag1":"Value1"}
app.service.MetricsManager().Register(myCounterMetricName, myCounter, myTags)	
```

### Publish

`Publish(data any) error`

This API pushes data to the EdgeX MessageBus using configured topic and returns an error if the EdgeX MessageBus is disabled in configuration

### PublishWithTopic

`PublishWithTopic(topic string, data any) error`

This API pushes data to the EdgeX MessageBus using a given topic and returns an error if the EdgeX MessageBus is disabled in configuration
