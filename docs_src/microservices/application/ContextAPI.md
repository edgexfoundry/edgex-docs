The context parameter passed to each function/transform provides operations and data associated with each execution of the pipeline. Let's take a look at a few of the properties that are available:

```go
type Context struct {
	// ID of the EdgeX Event (will be filled for a received JSON Event)
	EventID string
	
	// Checksum of the EdgeX Event (will be filled for a received CBOR Event)
	EventChecksum string
	
	// This is the ID used to track the EdgeX event through entire EdgeX framework.
	CorrelationID string
	
	// OutputData is used for specifying the data that is to be outputted. Leverage the .Complete() function to set.
	OutputData []byte
	
	// This holds the configuration for your service. This is the preferred way to access your custom application settings that have been set in the configuration.	
	Configuration common.ConfigurationStruct
	
	// LoggingClient is exposed to allow logging following the preferred logging strategy within EdgeX.
	LoggingClient logger.LoggingClient
	
	// EventClient exposes Core Data's EventClient API
	EventClient coredata.EventClient
	
	// ValueDescriptorClient exposes Core Data's ValueDescriptor API
	ValueDescriptorClient coredata.ValueDescriptorClient
	
	// CommandClient exposes Core Commands's Command API
	CommandClient command.CommandClient
	
	// NotificationsClient exposes Support Notification's Notifications API
	NotificationsClient notifications.NotificationsClient
	
	// RetryData holds the data to be stored for later retry when the pipeline function returns an error
	RetryData []byte
	
	// SecretProvider exposes the support for getting and storing secrets
	SecretProvider *security.SecretProvider

	// ResponseContentType sets a custom response type
	ResponseContentType string
}
```

## Clients

### LoggingClient

The `LoggingClient` exposed on the context is available to leverage logging libraries/service utilized throughout the EdgeX framework. The SDK has initialized everything so it can be used to log `Trace`, `Debug`, `Warn`, `Info`, and `Error` messages as appropriate. See [simple-filter-xml/main.go](https://github.com/edgexfoundry-holding/app-service-examples/blob/master/app-services/simple-filter-xml/main.go) for an example of how to use the `LoggingClient`.

### EventClient 

The `EventClient ` exposed on the context is available to leverage Core Data's `Event` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/clients/coredata/event.go#L35) for more details. This client is useful for querying events and is used by the [PushToCore](#pushtocore) convenience API described below.

### ValueDescriptorClient

The `ValueDescriptorClient ` exposed on the context is available to leverage Core Data's `ValueDescriptor` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/clients/coredata/value_descriptor.go#L29) for more details. Useful for looking up the value descriptor for a reading received.

### CommandClient 

The `CommandClient ` exposed on the context is available to leverage Core Command's `Command` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/clients/command/client.go#L28) for more details. Useful for sending commands to devices.

### NotificationsClient

The `NotificationsClient` exposed on the context is available to leverage Support Notifications' `Notifications` API. See [README](https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/clients/notifications/README.md) for more details. Useful for sending notifications. 

### Note about Clients

Each of the clients above is only initialized if the Clients section of the configuration contains an entry for the service associated with the Client API. If it isn't in the configuration the client will be `nil`. Your code must check for `nil` to avoid panic in case it is missing from the configuration. Only add the clients to your configuration that your Application Service will actually be using. All application services need `Core-Data` for version compatibility check done on start-up. The following is an example `Clients` section of a configuration.toml with all supported clients specified:

```
[Clients]
  [Clients.Logging]
  Protocol = "http"
  Host = "localhost"
  Port = 48061

  [Clients.CoreData]
  Protocol = 'http'
  Host = 'localhost'
  Port = 48080

  [Clients.Command]
  Protocol = 'http'
  Host = 'localhost'
  Port = 48082

  [Clients.Notifications]
  Protocol = 'http'
  Host = 'localhost'
  Port = 48060
```

## .PushToCore()
`.PushToCore(string deviceName, string readingName, byte[] value)` is used to push data to EdgeX Core Data so that it can be shared with other applications that are subscribed to the message bus that core-data publishes to. `deviceName` can be set as you like along with the `readingName` which will be set on the EdgeX event sent to CoreData. This function will return the new EdgeX Event with the ID populated, however the CorrelationId will not be available.

!!! note
    If validation is turned on in CoreServices then your deviceName and readingName must exist in the CoreMetadata and be properly registered in EdgeX. 

!!! warning
    Be aware that without a filter in your pipeline, it is possible to create an infinite loop when the Message Bus trigger is used. Choose your device-name and reading name appropriately.

## .Complete()
`.Complete([]byte outputData)` can be used to return data back to the configured trigger. In the case of an HTTP trigger, this would be an HTTP Response to the caller. In the case of a message bus trigger, this is how data can be published to a new topic per the configuration. 

## .SetRetryData()

`.SetRetryData(payload []byte)` can be used to store data for later retry. This is useful when creating a custom export function that needs to retry on failure when sending the data. The payload data will be stored for later retry based on `Store and Forward` configuration. When the retry is triggered, the function pipeline will be re-executed starting with the function that called this API. That function will be passed the stored data, so it is important that all transformations occur in functions prior to the export function. The `Context` will also be restored to the state when the function called this API. See [Store and Forward](#store-and-forward) for more details.

!!! note
    `Store and Forward` be must enabled when calling this API. 

## .GetSecrets()

`.GetSecrets(path string, keys ...string)` is used to retrieve secrets from the secret store. `path` specifies the type or location of the secrets to retrieve. If specified, it is appended to the base path from the exclusive secret store configuration. `keys` specifies the list of secrets to be retrieved. If no keys are provided then all the keys associated with the specified path will be returned.
