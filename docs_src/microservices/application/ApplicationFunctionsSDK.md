# App Functions SDK

Welcome the App Functions SDK for EdgeX. This sdk is meant to provide all the plumbing necessary for developers to get started in processing/transforming/exporting data out of EdgeX. 


## Context API

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
}
```

### LoggingClient

The `LoggingClient` exposed on the context is available to leverage logging libraries/service utilized throughout the EdgeX framework. The SDK has initialized everything so it can be used to log `Trace`, `Debug`, `Warn`, `Info`, and `Error` messages as appropriate. See [simple-filter-xml/main.go](https://github.com/edgexfoundry-holding/app-service-examples/blob/master/app-services/simple-filter-xml/main.go) for an example of how to use the `LoggingClient`.

### EventClient 

The `EventClient ` exposed on the context is available to leverage Core Data's `Event` API. See [interface definition](https://github.com/edgexfoundry/go-mod-core-contracts/blob/master/clients/coredata/event.go#L35) for more details. This client is useful for querying events and is used by the [MarkAsPushed](#markaspushed) convenience API described below.

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

### .MarkAsPushed()

`.MarkAsPushed()` is used to indicate to EdgeX Core Data that an event has been "pushed" and is no longer required to be stored. The scheduler service will purge all events that have been marked as pushed based on the configured schedule. By default, it is once daily at midnight. If you leverage the built in export functions (i.e. HTTP Export, or MQTT Export), then simply adding the MaskedAsPush function to you pipeline after the export function will take care of calling this API. 

### .PushToCore()
`.PushToCore(string deviceName, string readingName, byte[] value)` is used to push data to EdgeX Core Data so that it can be shared with other applications that are subscribed to the message bus that core-data publishes to. `deviceName` can be set as you like along with the `readingName` which will be set on the EdgeX event sent to CoreData. This function will return the new EdgeX Event with the ID populated, however the CorrelationId will not be available.

!!! note
    If validation is turned on in CoreServices then your deviceName and readingName must exist in the CoreMetadata and be properly registered in EdgeX. 

!!! warning
    Be aware that without a filter in your pipeline, it is possible to create an infinite loop when the Message Bus trigger is used. Choose your device-name and reading name appropriately.

### .Complete()
`.Complete([]byte outputData)` can be used to return data back to the configured trigger. In the case of an HTTP trigger, this would be an HTTP Response to the caller. In the case of a message bus trigger, this is how data can be published to a new topic per the configuration. 

### .SetRetryData()

`.SetRetryData(payload []byte)` can be used to store data for later retry. This is useful when creating a custom export function that needs to retry on failure when sending the data. The payload data will be stored for later retry based on `Store and Forward` configuration. When the retry is triggered, the function pipeline will be re-executed starting with the function that called this API. That function will be passed the stored data, so it is important that all transformations occur in functions prior to the export function. The `Context` will also be restored to the state when the function called this API. See [Store and Forward](#store-and-forward) for more details.

!!! note
    `Store and Forward` be must enabled when calling this API. 

### .GetSecrets()

`.GetSecrets(path string, keys ...string)` is used to retrieve secrets from the secret store. `path` specifies the type or location of the secrets to retrieve. If specified it is appended to the base path from the exclusive secret store configuration. `keys` specifies the secrets which to retrieve. If no keys are provided then all the keys associated with the specified path will be returned.

## Built-In Transforms/Functions 

All transforms define a type and a `New` function which is used to initialize an instance of the type with the  required parameters. These instances returned by these `New` functions give access to their appropriate pipeline function pointers when setting up the function pipeline.

```
E.G. NewFilter([] {"Device1", "Device2"}).FilterByDeviceName
```

### Filtering

There are two basic types of filtering included in the SDK to add to your pipeline. Theses provided Filter functions return a type of events.Model. If filtering results in no remaining data, the pipeline execution for that pass is terminated. If no values are provided for filtering, then data flows through unfiltered.

- `NewFilter([]string filterValues)` - This function returns a `Filter` instance initialized with the passed in filter values. This `Filter` instance is used to access the following filter functions that will operate using the specified filter values.
    - `FilterByDeviceName` - This function will filter the event data down to the specified device names and return the filtered data to the pipeline.
    - `FilterByValueDescriptor` - This function will filter the event data down to the specified device value descriptor and return the filtered data to the pipeline.

#### JSON Logic
- `NewJSONLogic(rule string)` - This function returns a `JSONLogic` instance initialized with the passed in JSON rule. The rule passed in should be a JSON string conforming to the specification here: http://jsonlogic.com/operations.html. 
    - `Evaluate` - This is the function that will be used in the pipeline to apply the JSON rule to data coming in on the pipeline. If the condition of your rule is met, then the pipeline will continue and the data will continue to flow to the next function in the pipeline. If the condition of your rule is NOT met, then pipeline execution stops. 

!!! note
    Only simple logic/filtering operators are supported. Manipulation of data via JSONLogic rules are not yet supported. For more advanced scenarios checkout [EMQ X Kuiper](https://github.com/emqx/kuiper).


### Encryption
There is one encryption transform included in the SDK that can be added to your pipeline. 

- `NewEncryption(key string, initializationVector string)` - This function returns a `Encryption` instance initialized with the passed in key and initialization vector. This `Encryption` instance is used to access the following encryption function that will use the specified key and initialization vector.
    - `EncryptWithAES` - This function receives a either a `string`, `[]byte`, or `json.Marshaller` type and encrypts it using AES encryption and returns a `[]byte` to the pipeline.

### Batch
Included in the SDK is an in-memory batch function that will hold on to your data before continuing the pipeline. There are three functions provided for batching each with their own strategy.

- `NewBatchByTime(timeInterval string)` - This function returns a `BatchConfig` instance with time being the strategy that is used for determining when to release the batched data and continue the pipeline. `timeInterval` is the duration to wait (i.e. `10s`). The time begins after the first piece of data is received. If no data has been received no data will be sent forward. 
- `NewBatchByCount(batchThreshold int)` - This function returns a `BatchConfig` instance with count being the strategy that is used for determining when to release the batched data and continue the pipeline. `batchThreshold` is how many events to hold on to (i.e. `25`). The count begins after the first piece of data is received and once the threshold is met, the batched data will continue forward and the counter will be reset.
- `NewBatchByTimeAndCount(timeInterval string, batchThreshold int)` - This function returns a `BatchConfig` instance with a combination of both time and count being the strategy that is used for determining when to release the batched data and continue the pipeline. Whichever occurs first will trigger the data to continue and be reset.
    - `Batch` - This function will apply the selected strategy in your pipeline.

### Conversion
There are two conversions included in the SDK that can be added to your pipeline. These transforms return a `string`.

 - `NewConversion()` - This function returns a `Conversion` instance that is used to access the following conversion functions: 
    - `TransformToXML`  - This function receives an `events.Model` type, converts it to XML format and returns the XML string to the pipeline. 
    - `TransformToJSON` - This function receives an `events.Model` type and converts it to JSON format and returns the JSON string to the pipeline.

### Compressions
There are two compression types included in the SDK that can be added to your pipeline. These transforms return a `[]byte`.

- `NewCompression()` - This function returns a `Compression` instance that is used to access the following compression functions:
    - `CompressWithGZIP`  - This function receives either a `string`,`[]byte`, or `json.Marshaler` type, GZIP compresses the data, converts result to base64 encoded string, which is returned as a `[]byte` to the pipeline.
    - `CompressWithZLIB` - This function receives either a `string`,`[]byte`, or `json.Marshaler` type, ZLIB compresses the data, converts result to base64 encoded string, which is returned as a `[]byte` to the pipeline.

### CoreData Functions
These are functions that enable interactions with the CoreData REST API. 

- `NewCoreData()` - This function returns a `CoreData` instance. This `CoreData` instance is used to access the following function(s).
    - `MarkAsPushed` - This function provides the MarkAsPushed function from the context as a First-Class Transform that can be called in your pipeline. [See Definition Above](#.MarkAsPushed()). The data passed into this function from the pipeline is passed along unmodifed since all required information is provided on the context (EventId, CorrelationId,etc.. )
    - `PushToCore` - This function provides the PushToCore function from the context as a First-Class Transform that can be called in your pipeline. [See Definition Above](#.PushToCore()). The data passed into this function from the pipeline is wrapped in an EdgeX event with the `deviceName` and `readingName` that were set upon the `CoreData` instance and then sent to Core Data service to be added as an event. Returns the new EdgeX event with ID populated.
    

!!! note
    If validation is turned on in Core Services then your `deviceName` and `readingName` must exist in the Core Metadata service and be properly registered in EdgeX. 

### Export Functions
There are few export functions included in the SDK that can be added to your pipeline. 

- `NewHTTPSender(url string, mimeType string, persistOnError bool)` - This function returns a `HTTPSender` instance initialized with the passed in url, mime type and persistOnError values. 

- `NewHTTPSenderWithSecretHeader(url string, mimeType string, persistOnError bool, httpHeaderSecretName string, secretPath string)` - This function returns a `HTTPSender` instance similar to the above function however will set up the `HTTPSender` to add a header to the HTTP request using the `httpHeaderSecretName` as both the header key  and the key to search for in the secret provider at `secretPath` leveraging secure storage of secrets. 
    - `HTTPPost` - This function receives either a `string`,`[]byte`, or `json.Marshaler` type from the previous function in the pipeline and posts it to the configured endpoint. If no previous function exists, then the event that triggered the pipeline, marshaled to json, will be used. If the post fails and `persistOnError`is `true` and `Store and Forward` is enabled, the data will be stored for later retry. See [Store and Forward](#store-and-forward) for more details. 

- `NewMQTTSecretSender(mqttConfig MQTTSecretConfig, persistOnError bool)` - This function returns a `MQTTSecretSender` instance initialized with the options specified in the `MQTTSecretConfig`.

```go
  type MQTTSecretConfig struct {
    // BrokerAddress should be set to the complete broker address i.e. mqtts://mosquitto:8883/mybroker
    BrokerAddress string
    // ClientId to connect with the broker with.
    ClientId string
    // The name of the path in secret provider to retrieve your secrets
    SecretPath string
    // AutoReconnect indicated whether or not to retry connection if disconnected
    AutoReconnect bool
    // Topic that you wish to publish to
    Topic string
    // QoS for MQTT Connection
    QoS byte
    // Retain setting for MQTT Connection
    Retain bool
    // SkipCertVerify
    SkipCertVerify bool
    // AuthMode indicates what to use when connecting to the broker. 
    // Options are "none", "cacert" , "usernamepassword", "clientcert".
    // If a CA Cert exists in the SecretPath then it will be used for 
    // all modes except "none". 
    AuthMode string
  }
```
Secrets in the secret provider may be located at any path however they must have some or all the follow keys at the specified `SecretPath`. 

- `username` - username to connect to the broker
- `password` - password used to connect to the broker
- `clientkey`- client private key in PEM format
- `clientcert` - client cert in PEM format
- `cacert` - ca cert in PEM format

What `AuthMode` you choose depends on what values are used. For example, if "none" is specified as auth mode all keys will be ignored. Similarly, if `AuthMode` is set to "clientcert" username and password will be ignored.

- **DEPRECATED**`NewMQTTSender(logging logger.LoggingClient, addr models.Addressable, keyCertPair *KeyCertPair, mqttConfig MqttConfig, persistOnError bool)` - This function returns a `MQTTSender` instance initialized with the passed in MQTT configuration . This `MQTTSender` instance is used to access the following  function that will use the specified MQTT configuration
  
    - `KeyCertPair` - This structure holds the Key and Certificate information for when using secure **TLS** connection to the broker. Can be `nil` if not using secure **TLS** connection. 
    
    - `MqttConfig` - This structure holds addition MQTT configuration settings. 
    
```go
        Qos            byte
        Retain         bool
        AutoReconnect  bool
        SkipCertVerify bool
        User           string
        Password       string
```

!!! note
    The `GO` complier will default these to `0`, `false` and `""`, so you only need to set the fields that your usage requires that differ from the default.

- `MQTTSend` - This function receives either a `string`,`[]byte`, or `json.Marshaler` type from the previous function in the pipeline and sends it to the specified MQTT broker. If no previous function exists, then the event that triggered the pipeline, marshaled to json, will be used. If the send fails and `persistOnError`is `true` and `Store and Forward` is enabled, the data will be stored for later retry. See [Store and Forward](#store-and-forward) for more details.

### Output Functions

There is one output function included in the SDK that can be added to your pipeline. 

- `NewOutput()` - This function returns a `Output` instance that is used to access the following output function: 
  
    - `SetOutput` - This function receives either a `string`,`[]byte`, or `json.Marshaler` type from the previous function in the pipeline and sets it as the output data for the pipeline to return to the configured trigger. If configured to use message bus, the data will be published to the message bus as determined by the `MessageBus` and `Binding` configuration. If configured to use HTTP trigger the data is returned as the HTTP response. 


!!! note
    Calling Complete() from the Context API in a custom function can be used in place of adding this function to your pipeline

## Configuration

Similar to other EdgeX services, configuration is first determined by the `configuration.toml` file in the `/res` folder. If `-cp` is passed to the application on startup, the SDK will leverage the specific configuration provider (i.e Consul) to push configuration from the file into the registry and monitor configuration from there. You will find the configuration under the `edgex/appservices/1.0/` key. There are two primary sections in the `configuration.toml` file that will need to be set that are specific to the AppFunctionsSDK. 

1) `[Binding]` - This specifies the [trigger](#triggers) type and associated data required to configure a trigger. 

```toml
  [Binding]
  Type=""
  SubscribeTopic=""
  PublishTopic=""
```

2) `[ApplicationSettings]` - Is used for custom application settings and is accessed via the ApplicationSettings() API. The ApplicationSettings API returns a `map[string] string` containing the contents on the ApplicationSetting section of the `configuration.toml` file.

```toml
 [ApplicationSettings]
 ApplicationName = "My Application Service"
```

## Error Handling

Each transform returns a `true` or `false` as part of the return signature. This is called the `continuePipeline` flag and indicates whether the SDK should continue calling successive transforms in the pipeline.

- `return false, nil` will stop the pipeline and stop processing the event. This is useful for example when filtering on values and nothing matches the criteria you've filtered on. 
- `return false, error`, will stop the pipeline as well and the SDK will log the error you have returned.
- `return true, nil` tells the SDK to continue, and will call the next function in the pipeline with your result.

The SDK will return control back to main when receiving a SIGTERM/SIGINT event to allow for custom clean up.

## Advanced Topics

The following items discuss topics that are a bit beyond the basic use cases of the Application Functions SDK when interacting with EdgeX.

### Configurable Functions Pipeline

This SDK provides the capability to define the functions pipeline via configuration rather than code by using the **app-service-configurable** application service. See the [App Service Configurable](./AppServiceConfigurable.md) section for more details.

### Using The Webserver

It is not uncommon to require your own API endpoints when building an app service. Rather than spin up your own webserver inside of your app (alongside the already existing running webserver), we've exposed a method that allows you add your own routes to the existing webserver. A few routes are reserved and cannot be used:

- /api/version
- /api/v1/ping
- /api/v1/metrics
- /api/v1/config
- /api/v1/trigger
- /api/v1/secrets

To add your own route, use the `AddRoute(route string, handler func(nethttp.ResponseWriter, *nethttp.Request), methods ...string) error` function provided on the sdk. Here's an example:

```go
edgexSdk.AddRoute("/myroute", func(writer http.ResponseWriter, req *http.Request) {
    context := req.Context().Value(appsdk.SDKKey).(*appsdk.AppFunctionsSDK) 
		context.LoggingClient.Info("TEST") // alternative to edgexSdk.LoggingClient.Info("TEST")
		writer.Header().Set("Content-Type", "text/plain")
		writer.Write([]byte("hello"))
		writer.WriteHeader(200)
}, "GET")
```
Under the hood, this simply adds the provided route, handler, and method to the gorilla `mux.Router` we use in the SDK. For more information on `gorilla mux` you can check out the github repo [here](https://github.com/gorilla/mux). 
You can access the resources such as the logging client by accessing the context as shown above -- this is useful for when your routes might not be defined in your main.go where you have access to the `edgexSdk` instance.

### Target Type

The target type is the object type of the incoming data that is sent to the first function in the function pipeline. By default this is an EdgeX `Event` since typical usage is receiving `events` from Core Data via Message Bus. 

For other usages where the data is not `events` coming from Core Data, the `TargetType` of the accepted incoming data can be set when the SDK instance is created. There are scenarios where the incoming data is not an EdgeX `Event`. One example scenario is 2 application services are chained via the Message Bus. The output of the first service back to the Messages Bus is inference data from analyzing the original input `Event`data.  The second service needs to be able to let the SDK know the target type of the input data it is expecting.

For usages where the incoming data is not `events`, the `TargetType` of the excepted incoming data can be set when the SDK instance is created. 

Example:

``` go
type Person struct {
    FirstName string `json:"first_name"`
    LastName  string `json:"last_name"`
}

edgexSdk := &appsdk.AppFunctionsSDK {
	ServiceKey: serviceKey, 
	TargetType: &Person{},
}
```

`TargetType` must be set to a pointer to an instance of your target type such as `&Person{}` . The first function in your function pipeline will be passed an instance of your target type, not a pointer to it. In the example above the first function in the pipeline would start something like:

``` go
func MyPersonFunction(edgexcontext *appcontext.Context, params ...interface{}) (bool, interface{}) {

	edgexcontext.LoggingClient.Debug("MyPersonFunction")

	if len(params) < 1 {
		// We didn't receive a result
		return false, nil
	}

	person, ok := params[0].(Person)
	if !ok {
        return false, errors.New("type received is not a Person")
	}
	
	// ....
```

The SDK supports un-marshaling JSON or CBOR encoded data into an instance of the target type. If your incoming data is not JSON or CBOR encoded, you then need to set the `TargetType` to  `&[]byte`.

If the target type is set to `&[]byte` the incoming data will not be un-marshaled.  The content type, if set, will be passed as the second parameter to the first function in your pipeline.  Your first function will be responsible for decoding the data or not.

### Command Line Options

The following command line options are available

```
  -c=<path>
  --confdir=<path>
        Specify an alternate configuration directory.
        
  -p=<profile>
  --profile=<profile>
        Specify a profile other than default.
  -f, 
  --file <name>               
  		Indicates name of the local configuration file. Defaults to configuration.toml

  -cp=<url>
  --configProvider=<url>           
  		Indicates to use Configuration Provider service at specified URL.
        URL Format: {type}.{protocol}://{host}:{port} ex: consul.http://localhost:8500
        No url, i.e. -cp, defaults to consul.http://localhost:8500
  -o    
  -overwrite
        Force overwrite configuration in the Configuration Provider with local values.
        
  -r    
  --registry
        Indicates the service should use the service Registry.
                
  -s    
  -skipVersionCheck
        Indicates the service should skip the Core Service's version compatibility check.
    
  -sk
  --serviceKey                
        Overrides the service key used with Registry and/or Configuration Providers.
        If the name provided contains the text `<profile>`, this text will be 
        replaced with the name of the profile used. 
```

Examples:

``` bash
simple-filter-xml -c=./res -p=http-export
```

or

``` bash
simple-filter-xml --confdir=./res -p=http-export -cp=consul.http://localhost:8500 --registry
```

### Environment Variable Overrides

All the configuration settings from the configuration.toml file can be overridden by environment variables. The environment variable names have the following format:

```toml
<TOML KEY>
<TOML SECTION>_<TOML KEY>
<TOML SECTION>_<TOML SUB-SECTION>_<TOML KEY>
```

!!! note
    With the Geneva release CamelCase environment variable names are deprecated. Instead use all uppercase environment variable names as in the example below.

Examples:

```toml
TOML   : FailLimit = 30
ENVVAR : FAILLIMIT=100

TOML   : [Logging]
		 EnableRemote = false
ENVVAR : LOGGING_ENABLEREMOTE=true

TOML   : [Clients]
  			[Clients.CoreData]
  			Host = 'localhost'
ENVVAR : CLIENTS_COREDATA_HOST=edgex-core-data
```

#### EDGEX_SERVICE_KEY

This environment variable overrides the service key used with the Configuration and/or Registry providers. Default is set by the application service. Also overrides any value set with the -sk/--serviceKey command-line option.

!!! note
    If the name provided contains the text `<profile>`, this text will be replaced with the name of the profile used.

!!! example
    `EDGEX_SERVICE_KEY: AppService-<profile>-mycloud` and if `profile: http-export` then service key will be "AppService-http-export-mycloud"


### EDGEX_CONFIGURATION_PROVIDER

This environment variable overrides the Configuration Provider connection information. The value is in the format of a URL.

```
EDGEX_CONFIGURATION_PROVIDER=consul.http://edgex-core-consul:8500

This sets the Configration Provider information fields as follows:
    Type: consul
    Host: edgex-core-consul
    Port: 8500
```

#### edgex_registry (DEPRECATED)

This environment variable overrides the Registry connection information and occurs every time the application service starts. The value is in the format of a URL.

!!! note
    This environment variable override has been deprecated in the Geneva Release. Instead, use configuration overrides of **REGISTRY_PROTOCOL** and/or **REGISTRY_HOST** and/or **REGISTRY_PORT**

```
EDGEX_REGISTRY=consul://edgex-core-consul:8500

This sets the Registry information fields as follows:
    Type: consul
    Host: edgex-core-consul
    Port: 8500
```

#### edgex_service (DEPRECATED)

This environment variable overrides the Service connection information. The value is in the format of a URL.

!!! note
    This environment variable override has been deprecated in the Geneva Release. Instead, use configuration overrides of **SERVICE_PROTOCOL** and/or **SERVICE_HOST** and/or **SERVICE_PORT**

```
EDGEX_SERVICE=http://192.168.1.2:4903

This sets the Service information fields as follows:
    Protocol: http
    Host: 192.168.1.2
    Port: 4903
```

#### edgex_profile / EDGEX_PROFILE

This environment variable overrides the command line `profile` argument. It will set the `profile` or replace the value passed via the `-p` or `--profile`, if one exists. This is useful when running the service via docker-compose.

!!! note
    The lower case version has been deprecated in the Geneva release. Instead use upper case version **EDGEX_PROFILE**

Using docker-compose:

```
  app-service-configurable-rules:
    image: edgexfoundry/docker-app-service-configurable:1.1.0
    environment: 
      - EDGEX_PROFILE : "rules-engine"
    ports:
      - "48095:48095"
    container_name: edgex-app-service-configurable
    hostname: edgex-app-service-configurable
    networks:
      edgex-network:
        aliases:
          - edgex-app-service-configurable
    depends_on:
      - data
      - command
```

This sets the `profile` so that the application service uses the `rules-engine` configuration profile which resides at `/res/rules-engine/configuration.toml`

!!! note
    EdgeX Services no longer use docker profiles. They use Environment Overrides in *the docker compose file to make the necessary changes to the configuration for running in Docker. See the **Environment Variable Overrides For Docker** section in the [App Service Configurable](./AppServiceConfigurable.md#environment-variable-overrides-for-docker) section for more details and an example.

#### EDGEX_STARTUP_DURATION

This environment variable overrides the default duration, 30 seconds, for a service to complete the start-up, aka bootstrap, phase of execution

#### EDGEX_STARTUP_INTERVAL

This environment variable overrides the retry interval or sleep time before a failure is retried during the start-up, aka bootstrap, phase of execution.

#### EDGEX_CONF_DIR

This environment variable overrides the configuration directory where the configuration file resides. Default is `./res` and also overrides any value set with the `-c/--confdir` command-line option.

#### EDGEX_CONFIG_FILE

This environment variable overrides the configuration file name. Default is `configutation.toml` and also overrides any value set with the -f/--file command-line option.

### Store and Forward

The Store and Forward capability allows for export functions to persist data on failure and for the export of the data to be retried at a later time. 

!!! note
    The order the data exported via this retry mechanism is not guaranteed to be the same order in which the data was initial received from Core Data

#### Configuration

Two sections of configuration have been added for Store and Forward.

`Writable.StoreAndForward` allows enabling, setting the interval between retries and the max number of retries. If running with Configuration Provider, these setting can be changed on the fly without having to restart the service.

```toml
  [Writable.StoreAndForward]
  Enabled = false
  RetryInterval = '5m'
  MaxRetryCount = 10
```

!!! note
    RetryInterval should be at least 1 second (eg. '1s') or greater. If a value less than 1 second is specified, 1 second will be used. Endless retries will occur when MaxRetryCount is set to 0. If MaxRetryCount is set to less than 0, a default of 1 retry will be used.

Database describes which database type to use, `mongodb` (DEPRECATED) or `redisdb`, and the information required to connect to the database. This section is required if Store and Forward is enabled, otherwise it is currently optional.

```toml
[Database]
Type = "redisdb"
Host = "localhost"
Port = 6379
Timeout = '30s'
Username = ""
Password = ""
```

#### How it works

When an export function encounters an error sending data it can call `SetRetryData(payload []byte)` on the Context. This will store the data for later retry. If the application service is stop and then restarted while stored data hasn't been successfully exported, the export retry will resume once the service is up and running again.

!!! note
    It is important that export functions return an error and stop pipeline execution after the call to `SetRetryData`. See [HTTPPost](https://github.com/edgexfoundry/app-functions-sdk-go/blob/master/pkg/transforms/http.go) function in SDK as an example

When the `RetryInterval` expires, the function pipeline will be re-executed starting with the export function that saved the data. The saved data will be passed to the export function which can then attempt to resend the data. 

!!! note
    The export function will receive the data as it was stored, so it is important that any transformation of the data occur in functions prior to the export function. The export function should only export the data that it receives.

One of three out comes can occur after the export retried has completed. 

1. Export retry was successful

    In this case the stored data is removed from the database and the execution of the pipeline functions after the export function, if any, continues. 

2. Export retry fails and retry count `has not been` exceeded

    In this case the store data is updated in the database with the incremented retry count

3. Export retry fails and retry count `has been` exceeded

    In this case the store data is removed from the database and never retried again.

!!! note
    Changing Writable.Pipeline.ExecutionOrder will invalidate all currently stored data and result in it all being removed from the database on the next retry. This is because the position of the *export* function can no longer be guaranteed and no way to ensure it is properly executed on the retry.

### Secrets

#### Configuration

All instances of App Services share the same database and database credentials. However, there are secrets for each App Service that are exclusive to the instance running. As a result, two separate configurations for secret store clients are used to manage shared and exclusive application service secrets.

The GetSecrets() and StoreSecrets() calls  use the exclusive secret store client to manage application secrets.

An example of configuration settings for each secret store client is below:

```toml
# Shared Secret Store
[SecretStore]
    Host = 'localhost'
    Port = 8200
    Path = '/v1/secret/edgex/appservice/'
    Protocol = 'https'
    RootCaCertPath = '/tmp/edgex/secrets/ca/ca.pem'
    ServerName = 'edgex-vault'
    TokenFile = '/tmp/edgex/secrets/edgex-appservice/secrets-token.json'
    # Number of attempts to retry retrieving secrets before failing to start the service.
    AdditionalRetryAttempts = 10
    # Amount of time to wait before attempting another retry
    RetryWaitPeriod = "1s"

	[SecretStore.Authentication]
		AuthType = 'X-Vault-Token'	

# Exclusive Secret Store
[SecretStoreExclusive]
    Host = 'localhost'
    Port = 8200
    Path = '/v1/secret/edgex/<app service key>/'
    Protocol = 'https'
    ServerName = 'edgex-vault'
    TokenFile = '/tmp/edgex/secrets/<app service key>/secrets-token.json'
    # Number of attempts to retry retrieving secrets before failing to start the service.
    AdditionalRetryAttempts = 10
    # Amount of time to wait before attempting another retry
    RetryWaitPeriod = "1s"

    [SecretStoreExclusive.Authentication]
    	AuthType = 'X-Vault-Token'
```

#### Storing Secrets

##### Secure Mode

When running an application service in secure mode, secrets can be stored in the secret store (Vault) by making an HTTP `POST` call to the secrets API route in the application service, `http://[host]:[port]/api/v1/secrets`. The secrets are stored and retrieved from the secret store based on values in the *SecretStoreExclusive* section of the configuration file. Once a secret is stored, only the service that added the secret will be able to retrieve it.  For secret retrieval see [Getting Secrets](#getting-secrets).

An example of the JSON message body is below.  

```json
{
  "path" : "MyPath",
  "secrets" : [
    {
      "key" : "MySecretKey",
      "value" : "MySecretValue"
    }
  ]
}
```

!!! note
    Path specifies the type or location of the secrets to store. It is appended to the base path from the SecretStoreExclusive configuration. An empty path is a valid configuration for a secret's location.

##### Insecure Mode

When running in insecure mode, the secrets are stored and retrieved from the *Writable.InsecureSecrets* section of the service's configuration toml file. Insecure secrets and their paths can be configured as below.

```toml
   [Writable.InsecureSecrets]    
      [Writable.InsecureSecrets.AWS]
        Path = 'aws'
        [Writable.InsecureSecrets.AWS.Secrets]
          username = 'aws-user'
          password = 'aws-pw'
      
      [Writable.InsecureSecrets.DB]
        Path = 'redisdb'
        [Writable.InsecureSecrets.DB.Secrets]
          username = ''
          password = ''
```

!!! note
    An empty path is a valid configuration for a secret's location 

#### Getting Secrets

Application Services can retrieve their secrets from the underlying secret store using the [GetSecrets()](#.GetSecrets()) API in the SDK. 

If in secure mode, the secrets are retrieved from the secret store based on the *SecretStoreExclusive* configuration values. 

If running in insecure mode, the secrets are retrieved from the *Writable.InsecureSecrets* configuration.

