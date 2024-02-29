---
title: App SDK - App Function Context API
---

# App Functions SDK - App Function Context API

The context parameter passed to each function/transform provides operations and data associated with each execution of the pipeline. 

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
    TriggerRetryFailedData()
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
    MetricsManager() bootstrapInterfaces.MetricsManager
    GetDeviceResource(profileName string, resourceName string) (dtos.DeviceResource, error)
    AddValue(key string, value string)
    RemoveValue(key string)
    GetValue(key string) (string, bool)
    GetAllValues() map[string]string
    ApplyValues(format string) (string, error)
    PipelineId() string
    Publish(data any) error
    PublishWithTopic(topic string, data any) error
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

Returns a `LoggingClient` to leverage logging libraries/service utilized throughout the EdgeX framework. The SDK has initialized everything, so it can be used to log `Trace`, `Debug`, `Warn`, `Info`, and `Error` messages as appropriate. 

!!! example "Example - LoggingClient"
    ```go
    ctx.LoggingClient().Info("Hello World")
    c.LoggingClient().Errorf("Some error occurred: %w", err)
    ```

### EventClient

`EventClient() interfaces.EventClient`

Returns an `EventClient` to leverage Core Data's `Event` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/event.go) for more details. This client is useful for querying events. Note if Core Data is not specified in the Clients configuration, this will return nil.

### ReadingClient

`ReadingClient() interfaces.ReadingClient`

Returns an `ReadingClient` to leverage Core Data's `Reading` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/reading.go) for more details. This client is useful for querying readings. Note if Core Data is not specified in the Clients configuration, this will return nil.

### CommandClient

`CommandClient() interfaces.CommandClient`

Returns a `CommandClient`  to leverage Core Command's `Command` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/command.go) for more details. Useful for sending commands to devices. Note if Core Command is not specified in the Clients configuration, this will return nil.

### NotificationClient

`NotificationClient() interfaces.NotificationClient`

Returns a `NotificationClient` to leverage Support Notifications' `Notifications` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/notification.go) for more details. Useful for sending notifications. Note if Support Notifications is not specified in the Clients configuration, this will return nil.

### SubscriptionClient

`SubscriptionClient() interfaces.SubscriptionClient`

Returns a `SubscriptionClient` to leverage Support Notifications' `Subscription` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/subscription.go) for more details. Useful for creating notification subscriptions. Note if Support Notifications is not specified in the Clients configuration, this will return nil.

### DeviceServiceClient

`DeviceServiceClient() interfaces.DeviceServiceClient`

Returns a `DeviceServiceClient` to leverage Core Metadata's `DeviceService` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/deviceservice.go) for more details. Useful for querying information about Device Services. Note if Core Metadata is not specified in the Clients configuration, this will return nil. 

### DeviceProfileClient

`DeviceProfileClient() interfaces.DeviceProfileClient`

Returns a `DeviceProfileClient` to leverage Core Metadata's `DeviceProfile` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/deviceprofile.go) for more details. Useful for querying information about Device Profiles and is used by the `GetDeviceResource` helper function below. Note if Core Metadata is not specified in the Clients configuration, this will return nil. 

### DeviceClient

`DeviceClient() interfaces.DeviceClient`

Returns a `DeviceClient` to leverage Core Metadata's `Device` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/{{edgexversion}}/clients/interfaces/device.go) for more details. Useful for querying information about Devices. Note if Core Metadata is not specified in the Clients configuration, this will return nil. 

### Note about Clients

Each of the clients above is only initialized if the Clients section of the configuration contains an entry for the service associated with the Client API. If it isn't in the configuration the client will be `nil`. Your code must check for `nil` to avoid panic in case it is missing from the configuration. Only add the clients to your configuration that your Application Service will actually be using. All application services need `Core-Data` for version compatibility check done on start-up. The following is an example `Clients` section of a configuration.yaml with all supported clients specified:

!!! example "Example - Client Configuration Section"
    ```yaml
    Clients:
      core-data:
        Protocol: http
        Host: localhost
        Port: 59880
    
      core-command:
        Protocol: http
        Host: localhost
        Port: 59882
    
      support-notifications:
        Protocol: http
        Host: localhost
        Port: 59860
    ```

!!! note
    Core Metadata client is required and provided by the App Services Common Configuration, so it is not included in the above example.

## Context Storage
The context API exposes a map-like interface that can be used to store custom data specific to a given pipeline execution.  This data is persisted for retry if needed.  Currently only strings are supported, and keys are treated as case-insensitive.  

There following values are seeded into the Context Storage when an Event is received:

- Profile Name (key to retrieve value is `interfaces.PROFILENAME`)
- Device Name  (key to retrieve value is `interfaces.DEVICENAME`)
- Source Name  (key to retrieve value is `interfaces.SOURCENAME`)
- Received Topic  (key to retrieve value is `interfaces.RECEIVEDTOPIC`)

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

This API will replace placeholders of the form `{context-key-name}` with the value found in the context at `context-key-name`.  Note that key matching is case-insensitive.  An error will be returned if any placeholders in the provided string do NOT have a corresponding entry in the context storage map.

## Secrets

### SecretProvider

`SecretProvider() interfaces.SecretProvider`

This API returns reference to the SecretProvider instance. See [Secret Provider API](../../../security/Ch-SecretProviderApi/) section for more details.

## Store and Forward

The APIs in this section are related to the Store and Forward capability. See the [Store and Forward](../details/StoreAndForward.md) section for more details.

### SetRetryData()

`SetRetryData(data []byte)`

This method can be used to store data for later retry. This is useful when creating a custom export function that needs to retry on failure. The payload data will be stored for later retry based on `Store and Forward` configuration. When the retry is triggered, the function pipeline will be re-executed starting with the function that called this API. That function will be passed the stored data, so it is important that all transformations occur in functions prior to the export function. The `Context` will also be restored to the state when the function called this API. See [Store and Forward](../AdvancedTopics/#store-and-forward) for more details.

!!! note
    `Store and Forward` must be enabled when calling this API, otherwise the data is ignored.

### TriggerRetryFailedData()

This method sets the flag to trigger retry of failed data once the current pipeline execution has completed. This method should only be called when the export of data was successful, which indicates that the recipient is accepting data. This allows the failed data to be retried as soon as the recipient is back on-line rather than waiting for the configured retry interval to expire.

!!! note
    `Store and Forward` must be enabled and failed data must be present, otherwise the call to this API is ignored.

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

### MetricsManager

`MetricsManager() bootstrapInterfaces.MetricsManager`

This API returns the Metrics Manager used to register counter, gauge, gaugeFloat64 or timer metric types from github.com/rcrowley/go-metrics

```go
myCounterMetricName := "MyCounter"
myCounter := gometrics.NewCounter()
myTags := map[string]string{"Tag1":"Value1"}
ctx.MetricsManager().Register(myCounterMetricName, myCounter, myTags)	
```

### Publish

`Publish(data any) error`

This API pushes data to the EdgeX MessageBus using configured topic and returns an error if the EdgeX MessageBus is disabled in configuration

### PublishWithTopic

`PublishWithTopic(topic string, data any) error`

This API pushes data to the EdgeX MessageBus using a given topic and returns an error if the EdgeX MessageBus is disabled in configuration