# Built-In Pipeline Functions

All pipeline functions define a type and a factory function which is used to initialize an instance of the type with the  required options. The instances returned by these factory functions give access to their appropriate pipeline function pointers when setting up the function pipeline.

!!! example
    ``` go
    NewFilterFor([] {"Device1", "Device2"}).FilterByDeviceName
    ```

## Batching

Included in the SDK is an in-memory batch function that will hold on to your data before continuing the pipeline. There are three functions provided for batching each with their own strategy.


| Factory Method | Description |
| -------------- | ----------- |
|NewBatchByTime(timeInterval string) | This function returns a `BatchConfig` instance with time being the strategy that is used for determining when to release the batched data and continue the pipeline. `timeInterval` is the duration to wait (i.e. `10s`). The time begins after the first piece of data is received. If no data has been received no data will be sent forward. 
``` go
// Example: 
NewBatchByTime("10s").Batch
```
| NewBatchByCount(batchThreshold int) | This function returns a `BatchConfig` instance with count being the strategy that is used for determining when to release the batched data and continue the pipeline. `batchThreshold` is how many events to hold on to (i.e. `25`). The count begins after the first piece of data is received and once the threshold is met, the batched data will continue forward and the counter will be reset.
``` go
// Example:
NewBatchByCount(10).Batch
```
| NewBatchByTimeAndCount(timeInterval string, batchThreshold int) | This function returns a `BatchConfig` instance with a combination of both time and count being the strategy that is used for determining when to release the batched data and continue the pipeline. Whichever occurs first will trigger the data to continue and be reset.
``` go
// Example:
NewBatchByTimeAndCount("30s", 10).Batch
```
### Batch

`Batch` - This pipeline function will apply the selected strategy in your pipeline. By default the batched data returned by this function is `[][]byte`. This is because this function doesn't need to know the type of the individual items batched. It simply marshals the items to JSON if the data isn't already a ` []byte`.

!!! edgey "Edgex 2.1"
    New for EdgeX 2.1 is the `IsEventData` flag on the `BatchConfig` instance. 

The `IsEventData` flag, when true, lets this function know that the data being batched is `Events` and to un-marshal the data a `[]Event` prior to returning the batched data.

!!! example "Batch with IsEventData flag set to true."
    ```
    batch := NewBatchByTimeAndCount("30s", 10)
    batch.IsEventData = true
    ...
    batch.Batch
    ```

!!! warning
    Keep memory usage in mind as you determine the thresholds for both time and count. The larger they are the more memory is required and could lead to performance issue. 

## Compression

There are two compression types included in the SDK that can be added to your pipeline. These transforms return a `[]byte`.

| Factory Method   | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| NewCompression() | This factory function returns a `Compression` instance that is used to access the compression functions. |

### GZIP

`CompressWithGZIP`  - This pipeline function receives either a `string`,`[]byte`, or `json.Marshaler` type, GZIP compresses the data, converts result to base64 encoded string, which is returned as a `[]byte` to the pipeline.

!!! example
    ```go
    NewCompression().CompressWithGZIP
    ```

### ZLIB

`CompressWithZLIB` - This pipeline function receives either a `string`,`[]byte`, or `json.Marshaler` type, ZLIB compresses the data, converts result to base64 encoded string, which is returned as a `[]byte` to the pipeline.

!!! example
    ```go
    NewCompression().CompressWithZLIB
    ```

## Conversion

There are two conversions included in the SDK that can be added to your pipeline. These transforms return a `string`.

| Factory Method  | Description                                                  |
| --------------- | ------------------------------------------------------------ |
| NewConversion() | This factory function returns a `Conversion` instance that is used to access the conversion functions. |

### JSON

`TransformToJSON` - This pipeline function receives an `dtos.Event` type and converts it to JSON format and returns the JSON string to the pipeline.

!!! example
    ```go
    NewConversion().TransformToJSON
    ```

### XML

`TransformToXML`  - This pipeline function receives an `dtos.Event` type, converts it to XML format and returns the XML string to the pipeline. 

!!! example
    ```go
    NewConversion().TransformToXML
    ```

## Core Data 

There is one Core Data function that enables interactions with the Core Data REST API

| Factory Method                                               | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| NewCoreDataSimpleReading(profileName string, deviceName string, resourceName string, valueType string) | This factory function returns a `CoreData` instance configured to push a `Simple` reading. The`CoreData` instance returned  is used to access core data functions. |
| NewCoreDataBinaryReading(profileName string, deviceName string, resourceName string, mediaType string) | This factory function returns a `CoreData` instance configured to push a `Binary` reading. The `CoreData` instance returned  is used to access core data functions. |
| NewCoreDataObejctReading(profileName string, deviceName string, resourceName string) | This factory function returns a `CoreData` instance configured to push an `Object` reading. The `CoreData` instance returned is used to access core data functions. |

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the `NewCoreData` factory function has been replaced with the `NewCoreDataSimpleReading` and `NewCoreDataBinaryReading` functions 

!!! edgey "EdgeX 2.1"
    The `NewCoreDataObejctReading`factory method is new for EdgeX 2.1

### Push to Core Data

`PushToCoreData` - This pipeline function provides the capability to push a new Event/Reading to Core Data. The data passed into this function from the pipeline is wrapped in an EdgeX Event with the Event and Reading metadata specified from the factory function options. The function returns the new EdgeX Event with ID populated.

!!! example
    ```go
    NewCoreDataSimpleReading("my-profile", "my-device", "my-resource", "string").PushToCoreData
    ```

## <a name="dataprotection"></a>Data Protection

There are two transforms included in the SDK that can be added to your pipeline for data protection. 

### Encryption (Deprecated)

!!! edgey "EdgeX 2.1"
    This is deprecated in EdgeX 2.1 - it is recommended to use the new `AESProtection` transform.  Please see [this security advisory](#TODO) for more detail.


| Factory Method                                               | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| NewEncryption(key string, initializationVector string)       | This function returns a `Encryption` instance initialized with the passed in `key` and `initialization vector`. This `Encryption` instance is used to access the following encryption function that will use the specified `key` and `initialization vector`. |
| NewEncryptionWithSecrets(secretPath string, secretName string, initializationVector string) | This function returns a `Encryption` instance initialized with the passed in `secret path`, `Secret name` and `initialization vector`. This `Encryption` instance is used to access the following encryption function that will use the encryption key from the Secret Store and the passed in `initialization vector`. It uses the passed in`secret path` and `secret name` to pull the encryption key from the Secret Store |

!!! edgey "EdgeX 2.0"
    New for EdgeX 2.0 is the ability to pull the encryption key from the Secret Store. The encryption key must be seeded into the Secret Store using the `/api/v2/secret` endpoint on the running instance of the Application Service prior to the Encryption function executing. See [App Functions SDK swagger](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/app-functions-sdk/2.0.0#/default/post_secret) for more details on this endpoint.

`EncryptWithAES` - This pipeline function receives either a `string`, `[]byte`, or `json.Marshaller` type and encrypts it using AES encryption and returns a `[]byte` to the pipeline.

!!! example
    ```go
    NewEncryption("key", "initializationVector").EncryptWithAES
    or
    NewEncryptionWithSecrets("aes", "aes-key", "initializationVector").EncryptWithAES)
    ```

!!! note
    The `algorithm` used used with app-service-configurable configuration to access this transform is `AES` 

### AESProtection

!!! edgey "Edgex 2.1"
    This transform provides AES 256 encryption with a random initialization vector and authentication using a SHA 512 hash.  It can only be configured using secrets.

| Factory Method                                               | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| NewAESProtection(secretPath string, secretName string)    | This function returns a `Encryption` instance initialized with the passed in `secretPath` and `secretName`|

It requires a 64-byte key from secrets which is split in half, the first half used for encryption, the second for generating the signature.

`Encrypt`: This pipeline function receives either a `string`, `[]byte`, or `json.Marshaller` type and encrypts it using AES256 encryption, signs it with a SHA512 hash and returns a `[]byte` to the pipeline of the following form:
        
| initialization vector | ciphertext | signing hash |
| ---------- | ---------- | ---- |
| 16 bytes   | variable bytes | 32 bytes |

!!! example    
```go
    transforms.NewAESProtection(secretPath, secretName).Encrypt(ctx, data)
```

!!! note
The `Algorithm` used with app-service-configurable configuration to access this transform is `AES256`

## Export

There are two export functions included in the SDK that can be added to your pipeline. 

### HTTP Export

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the signature of the `NewHTTPSenderWithSecretHeader` factory function has changed. See below for details.

| Factory Method                                               | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| NewHTTPSender(url string, mimeType string, persistOnError bool) | This factory function returns a `HTTPSender` instance initialized with the passed in url, mime type and persistOnError values. |
| NewHTTPSenderWithSecretHeader(url string, mimeType string, persistOnError bool, headerName string, secretPath string, secretName string) | This factory function returns a `HTTPSender` instance similar to the above function however will set up the `HTTPSender` to add a header  to the HTTP request using the `headerName ` for the field name and the `secretPath` and `secretName` to pull the header field value from the Secret Store. |
| NewHTTPSenderWithOptions(options HTTPSenderOptions)          | This factory function returns a `HTTPSender`using the passed in `options` to configure it. |

!!! edgey "EdgeX 2.0"
    New in EdgeX 2.0 is the ability to chain multiple instances of the HTTP exports to accomplish exporting to multiple destinations. The new `NewHTTPSenderWithOptions` factory function was added to allow for configuring all the options, including the new `ContinueOnSendError` and `ReturnInputData` options that enable this chaining. 

```go
// HTTPSenderOptions contains all options available to the sender
type HTTPSenderOptions struct {
	// URL of destination
	URL string
	// MimeType to send to destination
	MimeType string
	// PersistOnError enables use of store & forward loop if true
	PersistOnError bool
	// HTTPHeaderName to use for passing configured secret
	HTTPHeaderName string
	// SecretPath to search for configured secret
	SecretPath string
	// SecretName for configured secret
	SecretName string
	// URLFormatter specifies custom formatting behavior to be applied to configured URL.
	// If nothing specified, default behavior is to attempt to replace placeholders in the
	// form '{some-context-key}' with the values found in the context storage.
	URLFormatter StringValuesFormatter
	// ContinueOnSendError allows execution of subsequent chained senders after errors if true
	ContinueOnSendError bool
	// ReturnInputData enables chaining multiple HTTP senders if true
	ReturnInputData bool
}
```

#### HTTP POST

`HTTPPost` - This pipeline function receives either a `string`, `[]byte`, or `json.Marshaler` type from the previous function in the pipeline and posts it to the configured endpoint and returns the HTTP response. If no previous function exists, then the event that triggered the pipeline, marshaled to json, will be used. If the post fails and `persistOnError=true` and `Store and Forward` is enabled, the data will be stored for later retry. See [Store and Forward](#store-and-forward) for more details. If `ReturnInputData=true`  the function will return the data that it received instead of the HTTP response. This allows the following function in the pipeline to be another HTTP Export which receives the same data but is configured to send to a different endpoint. When chaining for multiple HTTP Exports you need to decide how to handle errors. Do you want to stop execution of the pipeline or continue so that the next HTTP Export function can attempt to export to its endpoint. This is where `ContinueOnSendError` comes in. If set to `true` the error is logged and the function returns the received data for the next function to use. `ContinueOnSendError=true` can only be used when `ReturnInputData=true` and cannot be use when `PersistOnError=true`.

!!! example
    **POST**              
    NewHTTPSender("https://myendpoint.com","application/json",false).HTTPPost 

    **PUT**                   
    NewHTTPSender("https://myendpoint.com","application/json",false).HTTPPut 
        
    **POST with secure header**
    NewHTTPSenderWithSecretHeader("https://myendpoint.com","application/json",false,"Authentication","/jwt","AuthToken").HTTPPost 
    
    ** PUT with secure header**
    NewHTTPSenderWithSecretHeader("https://myendpoint.com","application/json",false,"Authentication","/jwt","AuthToken").HTTPPPut 

#### HTTP PUT

`HTTPPut` - This pipeline function operates the same as `HTTPPost` but uses the `PUT` method rather than `POST`. 

#### URL Formatting

!!! edgey "EdgeX 2.0"
    URL Formatting is new in EdgeX 2.0

The configured URL is dynamically formatted prior to the POST/PUT request. The default formatter (used if `URLFormatter` is nil) simply replaces any placeholder text, `{key-name}`, in the configured URL with matching values from the new `Context Storage`. An error will occur if a specified placeholder does not exist in the `Context Storage`. See the [Context Storage](../AppFunctionContextAPI/#context-storage) documentation for more details on seeded values and storing your own values.

The `URLFormatter` option allows you to override the default formatter with your own custom URL formatting scheme.

!!! example
    Export the Events to  different endpoints base on their device name              
    `Url="http://myhost.com/edgex-events/{devicename}"` 

### MQTT Export

!!! edgey "EdgeX 2.0"
    New for EdgeX 2.0 is the the new `NewMQTTSecretSenderWithTopicFormatter` factory function. The deprecated `NewMQTTSender` factory function has been removed.

| Factory Method                                               | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| NewMQTTSecretSender(mqttConfig MQTTSecretConfig, persistOnError bool) | This factory function returns a `MQTTSecretSender` instance initialized with the options specified in the `MQTTSecretConfig` and `persistOnError `. |
| NewMQTTSecretSenderWithTopicFormatter(mqttConfig MQTTSecretConfig, persistOnError bool, topicFormatter StringValuesFormatter) | This factory function returns a `MQTTSecretSender` instance initialized with the options specified in the `MQTTSecretConfig`, `persistOnError ` and `topicFormatter `. See [Topic Formatting](#topic-formatting) below for more details. |

!!! edgey "EdgeX 2.0"
    New in EdgeX 2.0 the `KeepAlive` and `ConnectTimeout`  **MQTTSecretConfig** settings have been added.

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
	// KeepAlive is the interval duration between client sending keepalive ping to broker
	KeepAlive string
	// ConnectTimeout is the duration for timing out on connecting to the broker
	ConnectTimeout string
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

Secrets in the Secret Store may be located at any path however they must have some or all the follow keys at the specified `SecretPath`. 

- `username` - username to connect to the broker
- `password` - password used to connect to the broker
- `clientkey`- client private key in PEM format
- `clientcert` - client cert in PEM format
- `cacert` - ca cert in PEM format

The `AuthMode` setting you choose depends on what secret values above are used. For example, if "none" is specified as auth mode all keys will be ignored. Similarly, if `AuthMode` is set to "clientcert" username and password will be ignored.

#### Topic Formatting

!!! edgey "EdgeX 2.0"
    Topic Formatting is new in EdgeX 2.0

The configured Topic is dynamically formatted prior to publishing . The default formatter (used if `topicFormatter ` is nil) simply replaces any placeholder text, `{key-name}`, in the configured `Topic` with matching values from the new `Context Storage`. An error will occur if a specified placeholder does not exist in the `Context Storage`. See the [Context Storage](../AppFunctionContextAPI/#context-storage) documentation for more details on seeded values and storing your own values.

The `topicFormatter` option allows you to override the default formatter with your own custom topic formatting scheme.

## Filtering

There are four basic types of filtering included in the SDK to add to your pipeline. There is also an option to `Filter Out` specific items. These provided filter functions return a type of `dtos.Event`. If filtering results in no remaining data, the pipeline execution for that pass is terminated. If no values are provided for filtering, then data flows through unfiltered.

| Factory Method                   | Description |
|----------------------------------|-------------|
| NewFilterFor([]string filterValues) | This factory function returns a `Filter` instance initialized with the passed in filter values with `FilterOut` set to `false`. This `Filter` instance is used to access the following filter functions that will operate using the specified filter values. |
| NewFilterOut([]string filterValues) | This factory function returns a `Filter` instance initialized with the passed in filter values with `FilterOut` set to `true`. This `Filter` instance is used to access the following filter functions that will operate using the specified filter values. |



!!! edgey "EdgeX 2.0" 
    For EdgeX 2.0 the `NewFilter` factory function has been renamed to `NewFilterFor` and the new `NewFilterOut` factory function has been added.


``` go
type Filter struct {
    // Holds the values to be filtered
    FilterValues []string
    // Determines if items in FilterValues should be filtered out. If set to true all items found in the filter will be removed. If set to false all items found in the filter will be returned. If FilterValues is empty then all items will be returned.
	FilterOut    bool
}
```



!!! edgey "EdgeX 2.0"
    New for EdgeX 2.0 are the `FilterByProfileName` and `FilterBySourceName` pipeline functions. The `FilterByValueDescriptor` pipeline function has been renamed to `FilterByResourceName`



### By Profile Name

`FilterByProfileName` - This pipeline function will filter the event data down to **Events** that either have (For) or don't have (Out) the specified profiles names.  

!!! example
    ``` go
    NewFilterFor([] {"Profile1", "Profile2"}).FilterByProfileName
    ```

### By Device Name

`FilterByDeviceName` - This pipeline function will filter the event data down to **Events** that either have (For) or don't have (Out) the specified device names.  

!!! example
    ``` go
    NewFilterFor([] {"Device1", "Device2"}).FilterByDeviceName
    ```

### By Source Name

`FilterBySourceName` - This pipeline function will filter the event data down to **Events** that either have (For) or don't have (Out) the specified source names.  Source name is either the `resource name` or `command name` responsible for the Event creation.

!!! example
    ``` go
    NewFilterFor([] {"Source1", "Source2"}).FilterBySourceName
    ```


### By Resource Name

`FilterByResourceName` - This pipeline function will filter the Event's reading data down to **Readings** that either have (For) or don't have (Out) the specified resource names.  If the result of filtering is zero Readings remaining, the function terminates pipeline execution.

!!! example
    ``` go
    NewFilterFor([] {"Resource1", "Resource2"}).FilterByResourceName
    ```


## JSON Logic
| Factory Method                   | Description |
|----------------------------------|-------------|
| NewJSONLogic(rule string) | This factory function returns a `JSONLogic` instance initialized with the passed in JSON rule. The rule passed in should be a JSON string conforming to the specification here: http://jsonlogic.com/operations.html. |

### Evaluate

`Evaluate` - This is the pipeline function that will be used in the pipeline to apply the JSON rule to data coming in on the pipeline. If the condition of your rule is met, then the pipeline will continue and the data will continue to flow to the next function in the pipeline. If the condition of your rule is NOT met, then pipeline execution stops. 

!!! example
    ``` go
    NewJSONLogic("{ \"in\" : [{ \"var\" : \"device\" }, 
                  [\"Random-Integer-Device\",\"Random-Float-Device\"] ] }").Evaluate
    ```

!!! note
    Only  operations that return true or false are supported. See http://jsonlogic.com/operations.html# for the complete list of operations paying attention to return values. Any operator that returns manipulated data is currently not supported. For more advanced scenarios checkout [LF Edge eKuiper](https://github.com/lf-edge/ekuiper).

!!! tip
    Leverage http://jsonlogic.com/play.html to get your rule right before implementing in code. JSON can be a bit tricky to get right in code with all the escaped double quotes.

## Response Data

There is one response data function included in the SDK that can be added to your pipeline. 

| Factory Method    | Description                                                  |
| ----------------- | ------------------------------------------------------------ |
| NewResponseData() | This factory function returns a `ResponseData` instance that is used to access the following pipeline function below. |

### Content Type

`ResponseContentType` - This property is used to set the content-type of the response.

!!! example
    ``` go
    responseData := NewResponseData()
    responseData.ResponseContentType = "application/json"
    ```

### Set Response Data

`SetResponseData` - This pipeline function receives either a `string`,`[]byte`, or `json.Marshaler` type from the previous function in the pipeline and sets it as the response data that the pipeline returns to the configured trigger. If configured to use the`EdgeXMessageBus`trigger, the data will be published back to the EdgeX MessageBus as determined by the configuration. Similar, if  configured to use the`ExternalMQTT` trigger, the data will be published back to the external MQTT Broker as determined by the configuration. If configured to use `HTTP` trigger the data is returned as the HTTP response. 

!!! note
    Calling `SetResponseData()` and `SetResponseContentType()` from the Context API in a custom function can be used in place of adding this function to your pipeline.

## Tags

There is one Tags transform included in the SDK that can be added to your pipeline. 

| Factory Method                                     | Description                                                  |
| -------------------------------------------------- | ------------------------------------------------------------ |
| NewGenericTags(tags `map[string]interface{}`) Tags | This factory function returns a `Tags` instance initialized with the passed in collection of generic tag key/value pairs. This `Tags` instance is used to access the following Tags function that will use the specified collection of tag key/value pairs. This allows for generic complex types for the Tag values. |
| NewTags(tags `map[string]string`) Tags             | This factory function returns a `Tags` instance initialized with the passed in collection of tag key/value pairs. This `Tags` instance is used to access the following Tags function that will use the specified collection of tag key/value pairs. **This factor function has been Deprecated. Use `NewGenericTags` instead**. |

!!! edgey "EdgeX 2.1"
      The Tags property on Events in Edgex 2.1 has changed from `map[string]string` to `map[string]interface{}`. The new NewGenericTags() factory function takes this new definition and replaces the deprecated NewTags() factory function. 
     

### Add Tags

`AddTags` - This pipeline function receives an Edgex `Event` type and adds the collection of specified tags to the Event's `Tags` collection.

!!! example
    ``` go
    var myTags = map[string]interface{}{
    	"MyValue" : 123,
		"GatewayId": "HoustonStore000123",
    	"Coordinates": map[string]float32 {
    	   "Latitude": 29.630771,
           "Longitude": "-95.377603",
    	},
    }
    
    NewGenericTags(myTags).AddTags
    ```

