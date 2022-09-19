# App Function Context API
The context parameter passed to each function/transform provides operations and data associated with each execution of the pipeline. 

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the `AppFunctionContext` API replaces the direct access to the `appcontext.Context` struct. 

Let's take a look at its API:

```go
type AppFunctionContext interface {
    CorrelationID() string
    InputContentType() string
    SetResponseData(data []byte)
    ResponseData() []byte
    SetResponseContentType(string)
    ResponseContentType() string
    SetRetryData(data []byte)
    GetSecret(path string, keys ...string) (map[string]string, error)
    SecretsLastUpdated() time.Time
    SecretProvider() interfaces.SecretProvider
    LoggingClient() logger.LoggingClient
    EventClient() interfaces.EventClient
    CommandClient() interfaces.CommandClient
    NotificationClient() interfaces.NotificationClient
    SubscriptionClient() interfaces.SubscriptionClient
    DeviceServiceClient() interfaces.DeviceServiceClient
    DeviceProfileClient() interfaces.DeviceProfileClient
    DeviceClient() interfaces.DeviceClient
    MetricsManager() bootstrapInterfaces.MetricsManager
    PushToCore(event dtos.Event) (common.BaseWithIdResponse, error)
    GetDeviceResource(profileName string, resourceName string) (dtos.DeviceResource, error)
    AddValue(key string, value string)
    RemoveValue(key string)
    GetValue(key string) (string, bool)
    GetAllValues() map[string]string
    ApplyValues(format string) (string, error)
    PipelineId() string
    Clone() AppFunctionContext
}
```

## Response Data

### SetResponseData
`SetResponseData(data []byte)` 

This API sets the response data that will be returned to the trigger when pipeline execution is complete.

### ResponseData
`ResponseData()` 

This API returns the data that will be returned to the trigger when pipeline execution is complete.

### SetResponseContentType
`SetResponseContentType(string)` 

This API sets the content type that will be returned to the trigger when pipeline execution is complete.

### ResponseContentType
`ResponseContentType()` 

This API returns the content type that will be returned to the trigger when pipeline execution is complete.

## Clients

### LoggingClient

`LoggingClient() logger.LoggingClient`

Returns a `LoggingClient` to leverage logging libraries/service utilized throughout the EdgeX framework. The SDK has initialized everything so it can be used to log `Trace`, `Debug`, `Warn`, `Info`, and `Error` messages as appropriate. 

!!! example "Example - LoggingClient"
    ```go
    ctx.LoggingClient().Info("Hello World")
    c.LoggingClient().Errorf("Some error occurred: %w", err)
    ```

### EventClient

`EventClient() interfaces.EventClient`

Returns an `EventClient` to leverage Core Data's `Event` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/clients/interfaces/event.go) for more details. This client is useful for querying events and is used by the [PushToCore](#pushtocore) convenience API described below. Note if Core Data is not specified in the Clients configuration, this will return nil.

### CommandClient

`CommandClient() interfaces.CommandClient`

Returns a `CommandClient`  to leverage Core Command's `Command` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/clients/interfaces/command.go) for more details. Useful for sending commands to devices. Note if Core Command is not specified in the Clients configuration, this will return nil.

### NotificationClient

`NotificationClient() interfaces.NotificationClient`

Returns a `NotificationClient` to leverage Support Notifications' `Notifications` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/clients/interfaces/notification.go) for more details. Useful for sending notifications. Note if Support Notifications is not specified in the Clients configuration, this will return nil.

### SubscriptionClient

`SubscriptionClient() interfaces.SubscriptionClient`

Returns a `SubscriptionClient` to leverage Support Notifications' `Subscription` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/clients/interfaces/subscription.go) for more details. Useful for creating notification subscriptions. Note if Support Notifications is not specified in the Clients configuration, this will return nil.

### DeviceServiceClient

`DeviceServiceClient() interfaces.DeviceServiceClient`

Returns a `DeviceServiceClient` to leverage Core Metadata's `DeviceService` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/clients/interfaces/deviceservice.go) for more details. Useful for querying information about Device Services. Note if Core Metadata is not specified in the Clients configuration, this will return nil. 

### DeviceProfileClient

`DeviceProfileClient() interfaces.DeviceProfileClient`

Returns a `DeviceProfileClient` to leverage Core Metadata's `DeviceProfile` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/clients/interfaces/deviceprofile.go) for more details. Useful for querying information about Device Profiles and is used by the `GetDeviceResource` helper function below. Note if Core Metadata is not specified in the Clients configuration, this will return nil. 

### DeviceClient

`DeviceClient() interfaces.DeviceClient`

Returns a `DeviceClient` to leverage Core Metadata's `Device` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/clients/interfaces/device.go) for more details. Useful for querying information about Devices. Note if Core Metadata is not specified in the Clients configuration, this will return nil. 

### Note about Clients

Each of the clients above is only initialized if the Clients section of the configuration contains an entry for the service associated with the Client API. If it isn't in the configuration the client will be `nil`. Your code must check for `nil` to avoid panic in case it is missing from the configuration. Only add the clients to your configuration that your Application Service will actually be using. All application services need `Core-Data` for version compatibility check done on start-up. The following is an example `Clients` section of a configuration.toml with all supported clients specified:

!!! example "Example - Client Configuration Section"
    ```
    [Clients]
      [Clients.core-data]
      Protocol = 'http'
      Host = 'localhost'
      Port = 59880

      [Clients.core-metadata]
      Protocol = 'http'
      Host = 'localhost'
      Port = 59881
    
      [Clients.core-command]
      Protocol = 'http'
      Host = 'localhost'
      Port = 59882
    
      [Clients.support-notifications]
      Protocol = 'http'
      Host = 'localhost'
      Port = 59860
    ```

## Context Storage
The context API exposes a map-like interface that can be used to store custom data specific to a given pipeline execution.  This data is persisted for retry if needed.  Currently only strings are supported, and keys are treated as case-insensitive.  

There following values are seeded into the Context Storage when an Event is received:

- Profile Name (key to retrieve value is `interfaces.PROFILENAME`)
- Device Name  (key to retrieve value is `interfaces.DEVICENAME `)
- Source Name  (key to retrieve value is `interfaces.SOURCENAME  `)
- Received Topic  (key to retrieve value is `interfaces.RECEIVEDTOPIC   `)

!!! note
    Received Topic only available when the message was received from the Edgex MessageBus or External MQTT triggers.

Storage can be accessed using the following methods:

### AddValue
`AddValue(key string, value string)` 

This API stores a value for access within a pipeline execution

### RemoveValue
`RemoveValue(key string)`

This API  deletes a value stored in the context at the given key

### GetValue
`GetValue(key string) (string, bool)`

This API attempts to retrieve a value stored in the context at the given key

### GetAllValues
`GetAllValues() map[string]string`

This API returns a read-only copy of all data stored in the context

### ApplyValues
`ApplyValues(format string) (string, error)` 

This API will replace placeholders of the form `{context-key-name}` with the value found in the context at `context-key-name`.  Note that key matching is case insensitive.  An error will be returned if any placeholders in the provided string do NOT have a corresponding entry in the context storage map.

## Secrets

### GetSecret - DEPRECATED

`GetSecret(path string, keys ...string)`

This API is used to retrieve secrets from the secret store. `path` specifies the type or location of the secrets to retrieve. If specified, it is appended to the base path from the exclusive secret store configuration. `keys` specifies the list of secrets to be retrieved. If no keys are provided then all the keys associated with the specified path will be returned.

!!! warning
    GetSecret is deprecated and will be removed in EdgeX 3.0. Use `SecretProvider().GetSerect()`

### SecretsLastUpdated - DEPRECATED
`SecretsLastUpdated()`

This API returns that timestamp for when the secrets in the SecretStore where last updated.  Useful when a connection to external source needs to be redone when the credentials have been updated.

!!! warning
    SecretsLastUpdated is deprecated and will be removed in EdgeX 3.0. Use `SecretProvider().SecretsLastUpdated()`

### SecretProvider

`SecretProvider() interfaces.SecretProvider`

This API returns reference to the SecretProvider instance. See [Secret Provider API](../../../security/Ch-SecretProviderApi/) section for more details.

!!! edgey - "Edgex 2.3"
    SecretProvider() is new in EdgeX 2.3

## Miscellaneous

### Clone()
`Clone() AppFunctionContext`

This method returns a copy of the context that can be mutated independently where appropriate.  This can be useful when running operations that take AppFunctionContext in parallel.

### CorrelationID()
`CorrelationID() string`

This API returns the ID used to track the EdgeX event through entire EdgeX framework.

### PipelineId

`PipelineId() string`

This API returns the ID of the pipeline currently executing. Useful when logging messages from pipeline functions so the message contain the ID of the pipeline that executed the pipeline function.

### InputContentType()
`InputContentType() string`

This API returns the content type of the data that initiated the pipeline execution. Only useful when the TargetType for the pipeline is []byte, otherwise the data will be the type specified by TargetType.

### GetDeviceResource()
`GetDeviceResource(profileName string, resourceName string) (dtos.DeviceResource, error)`

This API retrieves the DeviceResource for the given profile / resource name. Results are cached to minimize HTTP traffic to core-metadata.

### PushToCore()
`PushToCore(event dtos.Event)`

This API is used to push data to EdgeX Core Data so that it can be shared with other applications that are subscribed to the message bus that core-data publishes to. This function will return the new EdgeX Event with the ID populated, along with any error encountered.  Note that CorrelationId will not be available.

!!! note
    If validation is turned on in CoreServices then your deviceName and readingName must exist in the CoreMetadata and be properly registered in EdgeX.

!!! warning
    Be aware that without a filter in your pipeline, it is possible to create an infinite loop when the Message Bus trigger is used. Choose your device-name and reading name appropriately.

### SetRetryData()
`SetRetryData(data []byte)`

This method can be used to store data for later retry. This is useful when creating a custom export function that needs to retry on failure. The payload data will be stored for later retry based on `Store and Forward` configuration. When the retry is triggered, the function pipeline will be re-executed starting with the function that called this API. That function will be passed the stored data, so it is important that all transformations occur in functions prior to the export function. The `Context` will also be restored to the state when the function called this API. See [Store and Forward](../AdvancedTopics/#store-and-forward) for more details.

!!! note
    `Store and Forward` be must enabled when calling this API, otherwise the data is ignored.

### MetricsManager

`MetricsManager() bootstrapInterfaces.MetricsManager`

This API returns the Metrics Manager used to register counter, gauge, gaugeFloat64 or timer metric types from github.com/rcrowley/go-metrics

```go
myCounterMetricName := "MyCounter"
myCounter := gometrics.NewCounter()
myTags := map[string]string{"Tag1":"Value1"}
ctx.MetricsManager().Register(myCounterMetricName, myCounter, myTags)	
```

