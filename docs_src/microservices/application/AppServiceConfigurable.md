# App Service Configurable

## Getting Started 

App-Service-Configurable is provided as an easy way to get started with processing data flowing through EdgeX. This service leverages the [App Functions SDK](https://github.com/edgexfoundry/app-functions-sdk-go) and provides a way for developers to use configuration instead of having to compile standalone services to utilize built in functions in the SDK. Please refer to [Available Configurable Pipeline Functions](#available-configurable-pipeline-functions)  section below for full list of built in functions that can be used in the configurable pipeline. 

To get started with the App-Service-Configurable, you'll want to start by determining which functions are required in your pipeline. Using a simple example, let's assume you wish to use the following functions from the SDK:

1. [FilterByDeviceName](./ApplicationFunctionsSDK.md#filtering) -  to filter events for a specific device.
2. [TransformToXML](./ApplicationFunctionsSDK.md#conversion) - to transform the data to XML
3. [HTTPPost](./ApplicationFunctionsSDK.md#export-functions) - to send the data to an HTTP endpoint that takes our XML data
4. [MarkAsPushed](./ApplicationFunctionsSDK.md#CoreData-Functions) - to call Core Data API to mark the event as having been pushed

Once the functions have been identified, we'll go ahead and build out the configuration in the `configuration.toml` file under the `[Writable.Pipeline]` section:

```toml
[Writable]
  LogLevel = 'DEBUG'
  [Writable.Pipeline]
    ExecutionOrder = "FilterByDeviceName, TransformToXML, HTTPPost, MarkAsPushed"
    [Writable.Pipeline.Functions.FilterByDeviceName]
      [Writable.Pipeline.Functions.FilterByDeviceName.Parameters]
        FilterValues = "Random-Float-Device, Random-Integer-Device"
    [Writable.Pipeline.Functions.TransformToXML]
    [Writable.Pipeline.Functions.MarkAsPushed]
    [Writable.Pipeline.Functions.HTTPPost]
      [Writable.Pipeline.Functions.HTTPPost.Parameters]
        url = "http://my.api.net/edgexdata"
        mimeType = "" #OPTIONAL - default application/json
```

The first line of note is `ExecutionOrder = "FilterByDeviceName, TransformToXML, HTTPPost,MarkAsPushed"`. This specifies the order in which to execute your functions. Each function specified here must also be placed in the `[Writeable.Pipeline.Functions]` section. 

Next, each function and its required information is listed. Each function typically has associated Parameters that must be configured to properly execute the function as designated by `[Writable.Pipeline.Functions.{FunctionName}.Parameters]`. Knowing which parameters are required for each function, can be referenced by taking a look at  the [Available Configurable Pipeline Functions](#available-configurable-pipeline-functions) section below. In a few cases, such as `TransformToXML`, `TransformToJSON`, SetOutputData`, etc. there are no parameters required.

!!! note
    By default, the configuration provided is set to use MessageBus as a trigger from CoreData. This means you must have EdgeX Running with devices sending data in order to trigger the pipeline. You can also change the trigger to be HTTP. For more on triggers, view the `Triggers`documentation located in the [Triggers](./Triggers.md) section.

That's it! Now we can run/deploy this service and the functions pipeline will process the data with functions we've defined.

## Environment Variable Overrides For Docker

EdgeX services no longer have docker specific profiles. They now rely on environment variable overrides in the docker compose files for the docker specific differences. The following environment settings are required in the compose files when using App Service Configurable.

```yaml
EDGEX_PROFILE : [target profile]
SERVICE_HOST : [service name]
SERVICE_PORT : [service port]
MESSAGEBUS_SUBSCRIBEHOST_HOST: edgex-core-data
CLIENTS_COREDATA_HOST: edgex-core-data
```

The following is an example docker compose entry for **App Service Configurable**:

```yaml
  app-service-configurable-rules:
    image: edgexfoundry/docker-app-service-configurable:1.1.0
    environment:
      EDGEX_PROFILE: rules-engine
      SERVICE_HOST: edgex-app-service-configurable-rules
      SERVICE_PORT: 48096
      MESSAGEBUS_SUBSCRIBEHOST_HOST: edgex-core-data
      CLIENTS_COREDATA_HOST: edgex-core-data
    ports:
      - "48096:48096"
    container_name: edgex-app-service-configurable-rules
    hostname: edgex-app-service-configurable-rules
    networks:
      - edgex-network
    depends_on:
      - data
```

!!! note
    **App Service Configurable** is designed to be run multiple times each with different profiles. This is why in the above example the name `edgex-app-service-configurable-rules` is used for the instance running the `rules-engine` profile.

## Deploying Multiple Instances using profiles

App Service Configurable was designed to be deployed as multiple instances with different purposes. Since the function pipeline is specified in the `configuration.toml` file, we can use this as a way to run each instance with a different function pipeline. App Service Configurable does not have the standard default configuration at `/res/configuration.toml`. This default configuration has been moved to the `sample` profile. This forces you to specify the profile for the configuration you would like to run. The profile is specified using the `-p/--profile=[profilename]` command line option or the `EDGEX_PROFILE=[profilename]` environment variable override. The profile name selected is used in the service key (`AppService-[profile name]`) to make each instance unique, e.g. `AppService-sample` when specifying `sample` as the profile.

!!! note
    If you need to run multiple instances with the same profile, e.g. `http-export`, but configured differently, you will need to override the service key with a custom name for one or more of the services. This is done with the `-sk/-serviceKey` command-line option or the `EDGEX_SERVICE_KEY` environment variable. See the [Command-line Options](./ApplicationFunctionsSDK.md#command-line-options) and [Environment Overrides](./ApplicationFunctionsSDK.md#environment-variable-overrides) sections for more detail.

The following profiles and their purposes are provided with App Service Configurable. 

- **blackbox-tests** - Profile used for black box testing  
- **http-export** - Starter profile used for exporting data via HTTP.  Requires further configuration which can easily be accomplished using environment variable overrides
    - Required:
        - `WRITABLE_PIPELINE_FUNCTIONS_HTTPPOSTJSON_PARAMETERS_URL: [Your URL]`

    - Optional: 
``` yaml
environment:
    - WRITABLE_PIPELINE_FUNCTIONS_HTTPPOSTJSON_PARAMETERS_PERSISTONERROR: ["true"/"false"]
    - WRITABLE_PIPELINE_FUNCTIONS_FILTERBYDEVICENAME_PARAMETERS_DEVICENAMES: "[comma separated list]"
    - WRITABLE_PIPELINE_FUNCTIONS_FILTERBYVALUEDESCRIPTOR_PARAMETERS_VALUEDESCRIPTORS: "[comma separated list]"
    - WRITABLE_PIPELINE_FUNCTIONS_FILTERBYVALUEDESCRIPTOR_PARAMETERS_FILTEROUT: ["true"/"false"]
```
- **mqtt-export** - Starter profile used for exporting data via MQTT. Requires further configuration which can easily be accomplished using environment variable overrides
    - Required:
        - `WRITABLE_PIPELINE_FUNCTIONS_MQTTSEND_ADDRESSABLE_ADDRESS: [Your Address]`

    - Optional: 

``` yaml
environment:
  - WRITABLE_PIPELINE_FUNCTIONS_MQTTSEND_ADDRESSABLE_PORT: ["your port"]
  - WRITABLE_PIPELINE_FUNCTIONS_MQTTSEND_ADDRESSABLE_PROTOCOL: [tcp or tcps]
  - WRITABLE_PIPELINE_FUNCTIONS_MQTTSEND_ADDRESSABLE_PUBLISHER: [your name]
  - WRITABLE_PIPELINE_FUNCTIONS_MQTTSEND_ADDRESSABLE_USER: [your username]
  - WRITABLE_PIPELINE_FUNCTIONS_MQTTSEND_ADDRESSABLE_PASSWORD: [your password]
  - WRITABLE_PIPELINE_FUNCTIONS_MQTTSEND_ADDRESSABLE_TOPIC: [your topic]
  - WRITABLE_PIPELINE_FUNCTIONS_MQTTSEND_PARAMETERS_QOS: ["your quality or service"]
  - WRITABLE_PIPELINE_FUNCTIONS_MQTTSEND_PARAMETERS_KEY: [your Key]  
  - WRITABLE_PIPELINE_FUNCTIONS_MQTTSEND_PARAMETERS_CERT: [your Certificate]
  - WRITABLE_PIPELINE_FUNCTIONS_MQTTSEND_PARAMETERS_AUTORECONNECT: ["true" or "false"]
  - WRITABLE_PIPELINE_FUNCTIONS_MQTTSEND_PARAMETERS_RETAIN: ["true" or "false"]
  - WRITABLE_PIPELINE_FUNCTIONS_MQTTSEND_PARAMETERS_PERSISTONERROR: ["true" or "false"]
```

- **rules-engine** - Profile used to push Event messages to the Rules Engine via **ZMQ** Message Bus.
- **rules-engine-mqtt** - Profile used to push Event messages to the Rules Engine via **MQTT** Message Bus.
- **rules-engine-redis** Profile used to push Event messages to the Rules Engine via **RedisStreams** Message Bus.
- **sample** - Sample profile with all available functions declared and a sample pipeline. Provided as a sample that can be copied and modified to create new custom profiles.

!!! note
    Functions can be declared in a profile but not used in the pipeline `ExecutionOrder`  allowing them to be added to the pipeline `ExecutionOrder` later at runtime if needed.

## What if my input data isn't an EdgeX Event ?

The default `TargetType` for data flowing into the functions pipeline is an EdgeX event. There are cases when this incoming data might not be an EdgeX event. In these cases the `Pipeline` can be configured using `UseTargetTypeOfByteArray=true` to set the `TargetType` to be a byte array, i.e. `byte[]`. The first function in the pipeline must then be one that can handle the `byte[]`data. The **compression**,  **encryption** and **export** functions are examples of pipeline functions that will take input data that is `byte[]`. Here is an example of how to configure the functions pipeline to **compress**, **encrypt** and then **export** the  `byte[]` data via HTTP.

```toml
[Writable]
  LogLevel = 'DEBUG'
  [Writable.Pipeline]
    UseTargetTypeOfByteArray = true
    ExecutionOrder = "CompressWithGZIP, EncryptWithAES, HTTPPost"
    [Writable.Pipeline.Functions.CompressWithGZIP]
    [Writable.Pipeline.Functions.EncryptWithAES]
      [Writable.Pipeline.Functions.EncryptWithAES.Parameters]
        Key = "aquqweoruqwpeoruqwpoeruqwpoierupqoweiurpoqwiuerpqowieurqpowieurpoqiweuroipwqure"
        InitVector = "123456789012345678901234567890"
    [Writable.Pipeline.Functions.HTTPPost]
      [Writable.Pipeline.Functions.HTTPPost.Parameters]
        url = "http://my.api.net/edgexdata"
```

If along with this pipeline configuration, you also configured the `Binding` to be `http` trigger,  you could then send any data to the app-service-configurable' s `/api/v1/trigger` endpoint and have it compressed, encrypted and sent to your configured URL above.

``` toml
[Binding]
Type="http"
```

## Available Configurable Pipeline Functions

Below are the functions that are available to use in the configurable functions pipeline (`[Writable.Pipeline]`) section of the configuration. The function names below can be added to the `Writable.Pipeline.ExecutionOrder` setting (comma separated list) and must also be present or added to the `[Writable.Pipeline.Functions]` section as `[Writable.Pipeline.Functions.{FunctionName}]`. Certain functions will also have the `[Writable.Pipeline.Functions.{FunctionName}.Parameters]` section where the function's parameters are configured. Please refer to the [Getting Started](#getting-started) section above for an example.

!!! note
    The `Parameters` section for each function is a key/value map of `string` values. So even tough the parameter is referred to as an Integer or Boolean, it has to be specified as a string, e.g. "20" or "true".

Please refer to the function's detailed documentation by clicking the function name below.

### [AddTags](../BuiltIn#tags)

**Parameters**

- `tags` - String containing comma separated list of tag key/value pairs. The tag key/value pairs are colon seperated

**Example**

```toml
    [Writable.Pipeline.Functions.AddTags]
      [Writable.Pipeline.Functions.AddTags.Parameters]
      tags = "GatewayId:HoustonStore000123,Latitude:29.630771,Longitude:-95.377603"
```

### [BatchByCount](../BuiltIn/#batch)

**Parameters**

- `BatchThreshold` - Number of items to batch before sending batched items to the next function in the pipeline.

**Example**

```toml
    [Writable.Pipeline.Functions.BatchByCount]
      [Writable.Pipeline.Functions.BatchByCount.Parameters]
      BatchThreshold = "30"
```

### [BatchByTime](../BuiltIn/#batch)

**Parameters**

- `TimeInterval` - Time duration to batch before sending batched items to the next function in the pipeline.

**Example**

```toml
    [Writable.Pipeline.Functions.BatchByTime]
      [Writable.Pipeline.Functions.BatchByTime.Parameters]
      TimeInterval = "60s"
```
### [BatchByTimeAndCount](../BuiltIn/#batch)
**Parameters**

- `BatchThreshold` - The number of items to batch before sending batched items to the next function in the pipeline.
- `TimeInterval` - Time duration to batch before sending batched items to the next function in the pipeline.

**Example**

```toml
    [Writable.Pipeline.Functions.BatchByTimeAndCount]
      [Writable.Pipeline.Functions.BatchByTimeAndCount.Parameters]
      BatchThreshold = "30"
      TimeInterval = "60s"
```
### [CompressWithGZIP](../BuiltIn/#gzip)

**Parameters**

none

**Example**

```toml
    [Writable.Pipeline.Functions.CompressWithGZIP]
```

### [CompressWithZLIB](../BuiltIn/#zlib)

**Parameters**

none

**Example**

```toml
    [Writable.Pipeline.Functions.CompressWithZLIB]
```

### [EncryptWithAES](../BuiltIn/#aes)
**Parameters**

- `Key` - Encryption key used for the AES encryption.
- `InitVector` - Initialization vector used for the AES encryption.

**Example**

```toml
    [Writable.Pipeline.Functions.EncryptWithAES]
      [Writable.Pipeline.Functions.EncryptWithAES.Parameters]
        Key = "aquqweoruqwpeoruqwpoeruqwpoierupqoweiurpoqwiuerpqowieurqpowieurpoqiweuroipwqure"
        InitVector = "123456789012345678901234567890"
```
### [FilterByDeviceName](../BuiltIn/#by-device-name)
**Parameters**

- `DeviceNames` - Comma separated list of device names for filtering
- `FilterOut`- Boolean indicating if the data matching the device names should be filtered out or filtered for.

**Example**

```toml
    [Writable.Pipeline.Functions.FilterByDeviceName]
      [Writable.Pipeline.Functions.FilterByDeviceName.Parameters]
        DeviceNames = "Random-Float-Device,Random-Integer-Device"
        FilterOut = "false"
```
### [FilterByValueDescriptor](../BuiltIn/#by-value-descriptor)
**Parameters**

- `ValueDescriptors` - Comma separated list of value descriptor (reading) names for filtering
- `FilterOut`- Boolean indicating if the data matching the value descriptor (reading) names should be filtered out or filtered for.

**Example**

```toml
    [Writable.Pipeline.Functions.FilterByValueDescriptor]
      [Writable.Pipeline.Functions.FilterByValueDescriptor.Parameters]
        ValueDescriptors = "RandomValue_Int8, RandomValue_Int64"
        FilterOut = "true"
```
### [HTTPPost](../BuiltIn/#http)
**Parameters**

- `Url` - HTTP endpoint to POST the data.
- `MimeType` - Optional mime type for the data. Defaults to application/json.
- `PersistOnError` - Indicates to persist the data if the POST fails. Store and Forward must also be enabled if this is set to "true".
- `SecretHeaderName` - Optional HTTP header name used when POSTing with authorization token. If specified, the Secret Store (Vault or [InsecureSecrets](../GeneralAppServiceConfig/#writable-insecuresecrets)) must contain the `<name>` secret at the specified `SecretPath`.
- `SecretPath` - Optional path in the secret store where to token is stored.

**Example**

```toml
    [Writable.Pipeline.Functions.HTTPPost]
      [Writable.Pipeline.Functions.HTTPPost.Parameters]
        Url = "http://my.api.net/edgexdata"
        MimeType = "" #OPTIONAL - default application/json
        PersistOnError = "false"
        SecretHeaderName = "" # This is the name used in the HTTP header and also used as the secret key
        SecretPath = ""
```
### [HTTPPostJSON](../BuiltIn/#http)
**Parameters**

- `Url` - HTTP endpoint to POST the data.
- `PersistOnError` - Indicates to persist the data if the POST fails. Store and Forward must also be enabled if this is set to "true".
- `SecretHeaderName` - Optional HTTP header name used when POSTing with authorization token. If specified, the Secret Store (Vault or [InsecureSecrets](../GeneralAppServiceConfig/#writable-insecuresecrets)) must contain the `<name>` secret at the specified `SecretPath`.
- `SecretPath` - Optional  path in the secret store where to token is stored. 

**Example**

```toml
    [Writable.Pipeline.Functions.HTTPPostJSON]
      [Writable.Pipeline.Functions.HTTPPostJSON.Parameters]
        Url = "https://my.api.net/edgexdata"
        PersistOnError = "true"
        SecretHeaderName = "Authorization" # This is the name used in the HTTP header and also used as the secret key
        SecretPath = "http"
```
### [HTTPPostXML](../BuiltIn/#http)
**Parameters**

- `Url` - HTTP endpoint to POST the data.
- `PersistOnError` - Indicates to persist the data if the POST fails. Store and Forward must also be enabled if this is set to "true".
- `SecretHeaderName` - Optional HTTP header name used when POSTing with authorization token. If specified, the Secret Store (Vault or [InsecureSecrets](../GeneralAppServiceConfig/#writable-insecuresecrets)) must contain the `<name>` secret at the specified `SecretPath`.
- `SecretPath` - Optional path in the secret store where to token is stored.

**Example**

```toml
    [Writable.Pipeline.Functions.HTTPPostXML]
      [Writable.Pipeline.Functions.HTTPPostXML.Parameters]
        Url = "http://my.api.net/edgexdata"
        PersistOnError = "false"
        SecretHeaderName = "" # This is the name used in the HTTP header and also used as the secret key
        SecretPath = ""
```
### [JSONLogic](../BuiltIn/#json-logic)
**Parameters**

- `Rule` - The JSON formatted rule that with be executed on the data by JSONLogic 

**Example**

```toml
    [Writable.Pipeline.Functions.JSONLogic]
      [Writable.Pipeline.Functions.JSONLogic.Parameters]
        Rule = "{ \"and\" : [{\"<\" : [{ \"var\" : \"temp\" }, 110 ]}, {\"==\" : [{ \"var\" : \"sensor.type\" }, \"temperature\" ]} ] }"

```
### [MarkAsPushed](../BuiltIn/#mark-as-pushed)

**Parameters**

none

**Example**

```toml
    [Writable.Pipeline.Functions.MarkAsPushed]
```
### [MQTTSecretSend](../BuiltIn/#mqtt)

**Parameters**

- `BrokerAddress` - URL specify the address of the MQTT Broker
- `Topic` - Topic to publish the data
- `ClientId` - Id to use when connection to the MQTT Broker
- `Qos` - MQTT Quality of Service setting to use (0, 1 or 2). Please refer [**here**](https://www.eclipse.org/paho/files/mqttdoc/MQTTClient/html/qos.html) for more details on QOS values
- `AutoReconnect` - Boolean specifying if reconnect should be automatic if connection to MQTT broker is lost
- `Retain` - Boolean  specifying if the MQTT Broker should save the last message published as the “Last Good Message” on that topic.
- `SkipVerify` - Boolean indicating if the certificate verification should be skipped. 
- `PersistOnError` - Indicates to persist the data if the POST fails. Store and Forward must also be enabled if this is set to "true".
- `AuthMode` - Mode of authentication to use when connecting to the MQTT Broker
    - `none` - No authentication required
    - `usernamepassword` - Use username and password authentication. The Secret Store (Vault or [InsecureSecrets](../GeneralAppServiceConfig/#writable-insecuresecrets)) must contain the `username` and `password` secrets.
    - `clientcert` - Use Client Certificate authentication. The Secret Store (Vault or [InsecureSecrets](../GeneralAppServiceConfig/#writable-insecuresecrets)) must contain the `clientkey` and `clientcert` secrets.
    - `cacert` - Use CA Certificate authentication. The Secret Store (Vault or [InsecureSecrets](../GeneralAppServiceConfig/#writable-insecuresecrets)) must contain the `cacert` secret.
- `SecretPath` - Path in the secret store where to authorization secrets are stored. 

**Examples**

```toml
    [Writable.Pipeline.Functions.MQTTSecretSend]
      [Writable.Pipeline.Functions.MQTTSecretSend.Parameters]
        BrokerAddress = "tcps://localhost:8883"
        Topic = "mytopic"
        ClientId = "myclientid"
        Qos="0"
        AutoReconnect="false"
        Retain="false"
        SkipVerify = "false"
        PersistOnError = "false"
        AuthMode = ""
        SecretPath = ""
```
```toml
    [Writable.Pipeline.Functions.MQTTSecretSend]
      [Writable.Pipeline.Functions.MQTTSecretSend.Parameters]
        BrokerAddress = "tcps://my-broker-host.com:8883"
        Topic = "mytopic"
        ClientId = "myclientid"
        Qos="2"
        AutoReconnect="true"
        Retain="true"
        SkipVerify = "false"
        PersistOnError = "true"
        AuthMode = "usernamepassword"
        SecretPath = "mqtt"
```
### [MQTTSend](../BuiltIn/#mqtt)

MQTTSend has been deprecated. Please use [MQTTSecretSend](#mqttsecretsend).

### [PushToCore](../BuiltIn/#push-to-core)

**Parameters**

none

**Example**

```toml
    [Writable.Pipeline.Functions.PushToCore]
```
### [SetOutputData](../BuiltIn/#output-functions)

**Parameters**

none

**Example**

```toml
    [Writable.Pipeline.Functions.SetOutputData]
```

### [TransformToJSON](../BuiltIn/#json)

**Parameters**

none

**Example**

```toml
    [Writable.Pipeline.Functions.TransformToJSON]
```

### [TransformToXML](../BuiltIn/#xml)
**Parameters**

none

**Example**

```toml
    [Writable.Pipeline.Functions.TransformToXML]
```
