# Built-In Transforms/Functions

All transforms define a type and a `New` function which is used to initialize an instance of the type with the  required parameters. These instances returned by these `New` functions give access to their appropriate pipeline function pointers when setting up the function pipeline.

!!! example
    ``` go
    NewFilter([] {"Device1", "Device2"}).FilterByDeviceName
    ```


## Filtering

There are two basic types of filtering included in the SDK to add to your pipeline. There is also an option to `Filter Out` specific items. These provided filter functions return a type of events.Model. If filtering results in no remaining data, the pipeline execution for that pass is terminated. If no values are provided for filtering, then data flows through unfiltered.

| Factory Method                   | Description |
|----------------------------------|-------------|
| NewFilter([]string filterValues)  | This function returns a `Filter` instance initialized with the passed in filter values. This `Filter` instance is used to access the following filter functions that will operate using the specified filter values. |


``` go
type Filter struct {
    // Holds the values to be filtered
    FilterValues []string
    // Determines if items in FilterValues should be filtered out. If set to true all items found in the filter will be removed. If set to false all items found in the filter will be returned. If FilterValues is empty then all items will be returned.
	FilterOut    bool
}
```

### By Device Name
`FilterByDeviceName` - This function will filter the event data down to the specified device names and return the filtered data to the pipeline.

``` go
NewFilter([] {"Device1", "Device2"}).FilterByDeviceName
```


### By Value Descriptor
`FilterByValueDescriptor` - This function will filter the event data down to the specified device value descriptor and return the filtered data to the pipeline.

``` go
NewFilter([] {"ValueDescriptor1", "ValueDescriptor2"}).FilterByValueDescriptor
```


### JSON Logic
| Factory Method                   | Description |
|----------------------------------|-------------|
| NewJSONLogic(rule string) | This function returns a `JSONLogic` instance initialized with the passed in JSON rule. The rule passed in should be a JSON string conforming to the specification here: http://jsonlogic.com/operations.html. |

`Evaluate` - This is the function that will be used in the pipeline to apply the JSON rule to data coming in on the pipeline. If the condition of your rule is met, then the pipeline will continue and the data will continue to flow to the next function in the pipeline. If the condition of your rule is NOT met, then pipeline execution stops. 


``` go
NewJSONLogic("{ \"in\" : [{ \"var\" : \"device\" }, [\"Random-Integer-Device\",\"Random-Float-Device\"] ] }").Evaluate
```

!!! note
    Only  operations that return true or false are supported. See http://jsonlogic.com/operations.html# for the complete list of operations paying attention to return values. Any operator that returns manipulated data is currently not supported. For more advanced scenarios checkout [EMQ X Kuiper](https://github.com/emqx/kuiper).

!!! tip
    Leverage http://jsonlogic.com/play.html to get your rule right before implementing in code. JSON can be a bit tricky to get right in code with all the escaped double quotes.

## Encryption
There is one encryption transform included in the SDK that can be added to your pipeline. 

| Factory Method                   | Description |
|----------------------------------|-------------|
| NewEncryption(key string, initializationVector string) | This function returns a `Encryption` instance initialized with the passed in key and initialization vector. This `Encryption` instance is used to access the following encryption function that will use the specified key and initialization vector. |

### AES
`EncryptWithAES` - This function receives a either a `string`, `[]byte`, or `json.Marshaller` type and encrypts it using AES encryption and returns a `[]byte` to the pipeline.

``` go
NewEncryption("key", "initializationVector").EncryptWithAES
```

## Tags

There is one Tags transform included in the SDK that can be added to your pipeline. 

| Factory Method                       | Description                                                  |
| ------------------------------------ | ------------------------------------------------------------ |
| NewTags(tags map[string]string) Tags | This function returns a `Tags` instance initialized with the passed in collection of tag key/value pairs. This `Tags` instance is used to access the following Tags function that will use the specified collection of tag key/value pairs. |

### AddTags

`AddTags` - This function receives an Edgex `Event` type and adds the collection of specified tags to the Event's `Tags` collection.

``` go
var myTags = map[string]string{
	"GatewayId": "HoustonStore000123",
	"Latitude":  "29.630771",
	"Longitude": "-95.377603",
}
NewTags(myTags).AddTags
```

## Batch

Included in the SDK is an in-memory batch function that will hold on to your data before continuing the pipeline. There are three functions provided for batching each with their own strategy.


| Factory Method                   | Description | 
|----------------------------------|-------------|
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
`Batch` - This function will apply the selected strategy in your pipeline.

!!! warning
    Keep memory usage in mind as you determine the thresholds for both time and count. The larger they are the more memory is required and could lead to performance issue. 

## Conversion
There are two conversions included in the SDK that can be added to your pipeline. These transforms return a `string`.

| Factory Method                   | Description |
|----------------------------------|-------------|
| NewConversion() | This function returns a `Conversion` instance that is used to access the conversion functions. |


### XML
`TransformToXML`  - This function receives an `events.Model` type, converts it to XML format and returns the XML string to the pipeline. 
```go
NewConversion().TransformToXML
```

### JSON
`TransformToJSON` - This function receives an `events.Model` type and converts it to JSON format and returns the JSON string to the pipeline.
```go
NewConversion().TransformToJSON
```

## Compressions
There are two compression types included in the SDK that can be added to your pipeline. These transforms return a `[]byte`.

| Factory Method                   | Description | 
|----------------------------------|-------------|
| NewCompression() | This function returns a `Compression` instance that is used to access the compression functions.

### GZIP
`CompressWithGZIP`  - This function receives either a `string`,`[]byte`, or `json.Marshaler` type, GZIP compresses the data, converts result to base64 encoded string, which is returned as a `[]byte` to the pipeline.
```go
NewCompression().CompressWithGZIP
```

### ZLIB
`CompressWithZLIB` - This function receives either a `string`,`[]byte`, or `json.Marshaler` type, ZLIB compresses the data, converts result to base64 encoded string, which is returned as a `[]byte` to the pipeline.
```go
NewCompression().CompressWithZLIB
```

## CoreData Functions
These are functions that enable interactions with the CoreData REST API. 

| Factory Method                   | Description | 
|----------------------------------|-------------|
| NewCoreData() | This function returns a `CoreData` instance. This `CoreData` instance is used to access core data functions.

### Push to Core
`PushToCore` - This function provides the PushToCore function from the context as a First-Class Transform that can be called in your pipeline. [See Definition Above](#.PushToCore()). The data passed into this function from the pipeline is wrapped in an EdgeX event with the `deviceName` and `readingName` that were set upon the `CoreData` instance and then sent to Core Data service to be added as an event. Returns the new EdgeX event with ID populated.
```go
NewCoreData().PushToCore
```

!!! note
    If validation is turned on in Core Services then your `deviceName` and `readingName` must exist in the Core Metadata service and be properly registered in EdgeX. 

## Export Functions
There are a few export functions included in the SDK that can be added to your pipeline. 

### HTTP
`HTTPPost` - This function receives either a `string`,`[]byte`, or `json.Marshaler` type from the previous function in the pipeline and posts it to the configured endpoint. If no previous function exists, then the event that triggered the pipeline, marshaled to json, will be used. If the post fails and `persistOnError`is `true` and `Store and Forward` is enabled, the data will be stored for later retry. See [Store and Forward](#store-and-forward) for more details. 

`HTTPPut` - This function operates the same as `HTTPPost` but uses the `PUT` method rather than `POST`. 

| Factory Method                   | Description |
|----------------------------------|-------------|
|NewHTTPSender(url string, mimeType string, persistOnError bool)| This function returns a `HTTPSender` instance initialized with the passed in url, mime type and persistOnError values. |
| NewHTTPSenderWithSecretHeader(url string, mimeType string, persistOnError bool, httpHeaderSecretName string, secretPath string) | This function returns a `HTTPSender` instance similar to the above function however will set up the `HTTPSender` to add a header to the HTTP request using the `httpHeaderSecretName` as both the header key  and the key to search for in the secret provider at `secretPath` leveraging secure storage of secrets. |

!!! example
    **POST**              
    NewHTTPSender("https://myendpoint.com","application/json",false).HTTPPost 
    //assumes TransformToJSON was used before this transform in the pipeline

    **PUT**                   
    NewHTTPSender("https://myendpoint.com","application/json",false).HTTPPut 
    //assumes TransformToJSON was used before this transform in the pipeline

    **POST with secure header**
    NewHTTPSenderWithSecretHeader("https://myendpoint.com","application/json",false,"Authentication","/jwt").HTTPPost 
    //assumes TransformToJSON was used before this transform in the pipeline and /jwt has been seeded into the secret provider with a key of Authentication

    ** PUT with secure header**
    NewHTTPSenderWithSecretHeader("https://myendpoint.com","application/json",false,"Authentication","/jwt").HTTPPPut 
    //assumes TransformToJSON was used before this transform in the pipeline and /jwt has been seeded into the secret provider with a key of Authentication

### MQTT

| Factory Method                   | Description |
|----------------------------------|-------------|
| NewMQTTSecretSender(mqttConfig MQTTSecretConfig, persistOnError bool) | This function returns a `MQTTSecretSender` instance initialized with the options specified in the `MQTTSecretConfig`. |

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


| Factory Method                   | Description |
|----------------------------------|-------------|
| **DEPRECATED** NewMQTTSender(logging logger.LoggingClient, addr models.Addressable, keyCertPair *KeyCertPair, mqttConfig MqttConfig, persistOnError bool) | This function returns a `MQTTSender` instance initialized with the passed in MQTT configuration . This `MQTTSender` instance is used to access the following  function that will use the specified MQTT configuration |

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

`MQTTSend` - This function receives either a `string`,`[]byte`, or `json.Marshaler` type from the previous function in the pipeline and sends it to the specified MQTT broker. If no previous function exists, then the event that triggered the pipeline, marshaled to json, will be used. If the send fails and `persistOnError`is `true` and `Store and Forward` is enabled, the data will be stored for later retry. See [Store and Forward](#store-and-forward) for more details.

## Output Functions

There is one output function included in the SDK that can be added to your pipeline. 

| Factory Method                   | Description |
|----------------------------------|-------------|
| NewOutput() | This function returns a `Output` instance that is used to access the following output function |

### Content Type
`ResponseContentType` - This property is used to set the content-type of the response.

``` go
output := NewOutput()
output.ResponseContentType = "application/json"
```

`SetOutput` - This function receives either a `string`,`[]byte`, or `json.Marshaler` type from the previous function in the pipeline and sets it as the output data for the pipeline to return to the configured trigger. If configured to use message bus, the data will be published to the message bus as determined by the `MessageBus` and `Binding` configuration. If configured to use HTTP trigger the data is returned as the HTTP response. 


!!! note
    Calling Complete() from the Context API in a custom function can be used in place of adding this function to your pipeline
