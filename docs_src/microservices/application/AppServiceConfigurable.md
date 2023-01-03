# App Service Configurable

## Getting Started 

App-Service-Configurable is provided as an easy way to get started with processing data flowing through EdgeX. This service leverages the [App Functions SDK](https://github.com/edgexfoundry/app-functions-sdk-go) and provides a way for developers to use configuration instead of having to compile standalone services to utilize built in functions in the SDK. Please refer to [Available Configurable Pipeline Functions](#available-configurable-pipeline-functions)  section below for full list of built-in functions that can be used in the configurable pipeline. 

To get started with App Service Configurable, you'll want to start by determining which functions are required in your pipeline. Using a simple example, let's assume you wish to use the following functions from the SDK:

1. [FilterByDeviceName](../BuiltIn/#by-device-name) -  to filter events for a specific device.
2. [Transform](../BuiltIn/#xml) - to transform the data to XML
3. [HTTPExport](../BuiltIn/#http-export) - to send the data to an HTTP endpoint that takes our XML data   

Once the functions have been identified, we'll go ahead and build out the configuration in the `configuration.toml` file under the `[Writable.Pipeline]` section.

!!! example "Example - Writable.Pipeline"
    ```toml
    [Writable]
    LogLevel = "DEBUG"
      [Writable.Pipeline]
        ExecutionOrder = "FilterByDeviceName, Transform, HTTPExport"
        [Writable.Pipeline.Functions]
          [Writable.Pipeline.Functions.FilterByDeviceName]
            [Writable.Pipeline.Functions.FilterByDeviceName.Parameters]
            FilterValues = "Random-Float-Device, Random-Integer-Device"
          [Writable.Pipeline.Functions.Transform]
            [Writable.Pipeline.Functions.Transform.Parameters]
            Type = "xml"
          [Writable.Pipeline.Functions.HTTPExport]
            [Writable.Pipeline.Functions.HTTPExport.Parameters]
            Method = "post" 
            MimeType = "application/xml" 
            Url = "http://my.api.net/edgexdata"
    ```

The first line of note is `ExecutionOrder = "FilterByDeviceName, Transform, HTTPExport"`. This specifies the order in which to execute your functions. Each function specified here must also be placed in the `[Writeable.Pipeline.Functions]` section. 

Next, each function and its required information is listed. Each function typically has associated Parameters that must be configured to properly execute the function as designated by `[Writable.Pipeline.Functions.{FunctionName}.Parameters]`. Knowing which parameters are required for each function, can be referenced by taking a look at  the [Available Configurable Pipeline Functions](#available-configurable-pipeline-functions) section below.

!!! note
    By default, the configuration provided is set to use `EdgexMessageBus` as a trigger. This means you must have EdgeX Running with devices sending data in order to trigger the pipeline. You can also change the trigger to be HTTP. For more details on triggers, view the `Triggers`documentation located in the [Triggers](./Triggers.md) section.

That's it! Now we can run/deploy this service and the functions pipeline will process the data with functions we've defined.

## Pipeline Per Topics

!!! edgey "EdgeX 2.1"
    Pipeline Per Topics is new for EdgeX 2.1

The above pipeline configuration in [Getting Started](#getting-started) section is the preferred way if your use case only requires a single functions pipeline. For use cases that require multiple functions pipelines in order to process the data differently based on the `profile`, `device` or `source` for the Event, there is the Pipeline Per Topics feature. This feature allows multiple pipelines to be configured in the `[Writable.Pipeline.PerTopicPipelines]`section. This section is a map of pipelines. The map key must be unique , but isn't used so can be any value. Each pipleline is defined by the following configuration settings:

- Id - This is the unique ID given to each pipeline
- Topics - Comma separated list of topics that control when the pipeline is executed. See [Pipeline Per Topics](../AdvancedTopics/#pipeline-per-topics)  for details on using wildcards in the topic.
- ExecutionOrder - This is the list of functions, in order, that the pipeline will execute. Same as `ExecutionOrder` in the above example in the  [Getting Started](#getting-started) section

!!! example "Example - Writable.Pipeline.PerTopicPipelines"
    In this example Events from the device  `Random-Float-Device` are transformed to JSON and then HTTP exported. At the same time, Events for the source `Int8`  are transformed to XML and then HTTP exported to same endpoint. Note the custom naming for `TransformJson` and `TransformXml`. This is taking advantage of the [Multiple Instances of a Function](#multiple-instances-of-a-function) described below.

    ```toml
    [Writable]
    LogLevel = "DEBUG"
      [Writable.Pipeline]
        [Writable.Pipeline.PerTopicPipelines]
          [Writable.Pipeline.PerTopicPipelines.float]
          Id = "float-pipeline"
          Topics = "edgex/events/device/#/Random-Float-Device/#, edgex/events/device/#/Random-Integer-Device/#"
          ExecutionOrder = "TransformJson, HTTPExport"
          [Writable.Pipeline.PerTopicPipelines.int8]
          Id = "int8-pipeline"
          Topic = "edgex/events/device/#/#/Int8"
          ExecutionOrder = "TransformXml, HTTPExport"  
        [Writable.Pipeline.Functions]
          [Writable.Pipeline.Functions.FilterByDeviceName]
            [Writable.Pipeline.Functions.FilterByDeviceName.Parameters]
            FilterValues = "Random-Float-Device, Random-Integer-Device"
          [Writable.Pipeline.Functions.TransformJson]
            [Writable.Pipeline.Functions.TransformJson.Parameters]
            Type = "json"
          [Writable.Pipeline.Functions.TransformXml]
            [Writable.Pipeline.Functions.TransformXml.Parameters]
            Type = "xml"        
          [Writable.Pipeline.Functions.HTTPExport]
            [Writable.Pipeline.Functions.HTTPExport.Parameters]
            Method = "post" 
            MimeType = "application/xml" 
            Url = "http://my.api.net/edgexdata"
    ```

!!! note
    The `Pipeline Per Topics` feature is targeted for EdgeX MessageBus and External MQTT triggers, but can be used with Custom or HTTP triggers. When used with the HTTP trigger the incoming topic will always be `blank`, so the pipeline's topics must contain a single topic set to the `#` wildcard so that all messages received are processed by the pipeline.

## Environment Variable Overrides For Docker

EdgeX services no longer have docker specific profiles. They now rely on environment variable overrides in the docker compose files for the docker specific differences.

!!! example "Example - Environment settings required in the compose files for App Service Configurable "
    ```yaml
          EDGEX_PROFILE : [target profile]
          SERVICE_HOST : [services network host name]
          EDGEX_SECURITY_SECRET_STORE: "false" # only need to disable as default is true
          CLIENTS_CORE_COMMAND_HOST: edgex-core-command
          CLIENTS_CORE_DATA_HOST: edgex-core-data
          CLIENTS_CORE_METADATA_HOST: edgex-core-metadata
          CLIENTS_SUPPORT_NOTIFICATIONS_HOST: edgex-support-notifications
          CLIENTS_SUPPORT_SCHEDULER_HOST: edgex-support-scheduler
          DATABASES_PRIMARY_HOST: edgex-redis
          MESSAGEQUEUE_HOST: edgex-redis
          REGISTRY_HOST: edgex-core-consul
          TRIGGER_EDGEXMESSAGEBUS_PUBLISHHOST_HOST: edgex-redis
          TRIGGER_EDGEXMESSAGEBUS_SUBSCRIBEHOST_HOST: edgex-redis
    ```

!!! example - "Example - Docker compose entry for **App Service Configurable** in no-secure compose file"
    ```yaml
      app-service-rules:
        container_name: edgex-app-rules-engine
        depends_on:
        - consul
        - data
        environment:
          CLIENTS_CORE_COMMAND_HOST: edgex-core-command
          CLIENTS_CORE_DATA_HOST: edgex-core-data
          CLIENTS_CORE_METADATA_HOST: edgex-core-metadata
          CLIENTS_SUPPORT_NOTIFICATIONS_HOST: edgex-support-notifications
          CLIENTS_SUPPORT_SCHEDULER_HOST: edgex-support-scheduler
          DATABASES_PRIMARY_HOST: edgex-redis
          EDGEX_PROFILE: rules-engine
          EDGEX_SECURITY_SECRET_STORE: "false"
          MESSAGEQUEUE_HOST: edgex-redis
          REGISTRY_HOST: edgex-core-consul
          SERVICE_HOST: edgex-app-rules-engine
          TRIGGER_EDGEXMESSAGEBUS_PUBLISHHOST_HOST: edgex-redis
          TRIGGER_EDGEXMESSAGEBUS_SUBSCRIBEHOST_HOST: edgex-redis
        hostname: edgex-app-rules-engine
        image: edgexfoundry/app-service-configurable:2.0.0
        networks:
          edgex-network: {}
        ports:
        - 127.0.0.1:59701:59701/tcp
        read_only: true
        security_opt:
        - no-new-privileges:true
        user: 2002:2001
    ```

!!! note
    **App Service Configurable** is designed to be run multiple times each with different profiles. This is why in the above example the name `edgex-app-rules-engine` is used for the instance running the `rules-engine` profile.

## Deploying Multiple Instances using profiles

App Service Configurable was designed to be deployed as multiple instances for different purposes. Since the function pipeline is specified in the `configuration.toml` file, we can use this as a way to run each instance with a different function pipeline. App Service Configurable does not have the standard default configuration at `/res/configuration.toml`. This default configuration has been moved to the `sample` profile. This forces you to specify the profile for the configuration you would like to run. The profile is specified using the `-p/--profile=[profilename]` command line option or the `EDGEX_PROFILE=[profilename]` environment variable override. The profile name selected is used in the service key (`app-[profile name]`) to make each instance unique, e.g. `AppService-sample` when specifying `sample` as the profile.

!!! edgey "Edgex 2.0"
    Default service key for App Service Configurable instances has changed in Edgex 2.0 from `AppService-[profile name]` to `app-[profile name]`

!!! note
    If you need to run multiple instances with the same profile, e.g. `http-export`, but configured differently, you will need to override the service key with a custom name for one or more of the services. This is done with the `-sk/-serviceKey` command-line option or the `EDGEX_SERVICE_KEY` environment variable. See the [Command-line Options](./ApplicationFunctionsSDK.md#command-line-options) and [Environment Overrides](./ApplicationFunctionsSDK.md#environment-variable-overrides) sections for more detail.

!!! note
    Functions can be declared in a profile but not used in the pipeline `ExecutionOrder`  allowing them to be added to the pipeline `ExecutionOrder` later at runtime if needed.

The following profiles and their purposes are provided with App Service Configurable. 

### rules-engine

Profile used to push Event messages to the Rules Engine via the **Redis Pub/Sub** Message Bus. This is used in the default docker compose files for the `app-rules-engine` service

One can optionally add Filter function via environment overrides

- `WRITABLE_PIPELINE_EXECUTIONORDER: "FilterByDeviceName, HTTPExport"`
- `WRITABLE_PIPELINE_FUNCTIONS_FILTERBYDEVICENAME_PARAMETERS_DEVICENAMES: "[comma separated list]"`

There are many optional functions and parameters provided in this profile. See the [complete profile](https://github.com/edgexfoundry/app-service-configurable/blob/master/res/rules-engine/configuration.toml) for more details

### http-export

Starter profile used for exporting data via HTTP.  Requires further configuration which can easily be accomplished using environment variable overrides

Required:

- `WRITABLE_PIPELINE_FUNCTIONS_HTTPEXPORT_PARAMETERS_URL: [Your URL]`

    There are many more optional functions and parameters provided in this profile. See the [complete profile](https://github.com/edgexfoundry/app-service-configurable/blob/v2.0.0/res/http-export/configuration.toml) for more details.

### metrics-influxdb

!!! edgey "Edgex 2.2"
    The `metrics-influxdb` profile is new for Edgex 2.2

Starter profile used for exporting telemetry data from other EdgeX services to InfluxDB via HTTP export. This profile configures the service to receive telemetry data from other services, transform it to Line Protocol syntax, batch the data and then export it to an InfluxDB service via HTTP. Requires further configuration which can easily be accomplished using environment variable overrides.

Required:

- `WRITABLE_PIPELINE_FUNCTIONS_HTTPEXPORT_PARAMETERS_URL: [Your InfluxDB URL]`
    - Example value: `"http://localhost:8086/api/v2/write?org=metrics&bucket=edgex&precision=ns"``
  
- ``WRITABLE_INSECURESECRETS_INFLUXDB_SECRETS_TOKEN`: [Your InfluxDB Token]
    - Example value: `"Token 29ER8iMgQ5DPD_icTnSwH_77aUhSvD0AATkvMM59kZdIJOTNoJqcP-RHFCppblG3wSOb7LOqjp1xubA80uaWhQ=="`
    
    - If using secure mode, store the token in the service's secret store via POST to the service's `/secret` endpoint 
    
    
    !!! example - "Example JSON to post to /secret endpoint"
        ```json
        {
            "apiVersion":"v2",
            "path":"influxdb",
            "secretData":[
            {
                "key":"Token",
                "value":"Token 29ER8iMgQ5DPD_icTnSwH_77aUhSvD0AATkvMM59kZdIJOTNoJqcP-RHFCppblG3wSOb7LOqjp1xubA80uaWhQ=="
            }]
        }
        ```

Optional Additional Tags:

- `WRITABLE_PIPELINE_FUNCTIONS_TOLINEPROTOCOL_PARAMETERS_TAGS: <your additional tags>`
    - Currently set to empty string
    - Example value: `"tag1:value1, tag2:value2"

Optional Batching parameters (see [Batch function](#batch) for more details):

- `WRITABLE_PIPELINE_FUNCTIONS_BATCH_PARAMETERS_MODE: <your batch mode>`
    - Currently set to `"bytimecount"`
        - Valid values are `"bycount"`, `"bytime"` or `"bytimecount"``
- ``WRITABLE_PIPELINE_FUNCTIONS_BATCH_PARAMETERS_BATCHTHRESHOLD: <your batch threshold count>`
    - Currently set to `100`
- `WRITABLE_PIPELINE_FUNCTIONS_BATCH_PARAMETERS_TIMEINTERVAL: <your batch time interval>`
    - Currently set to `"60s"`

### mqtt-export

Starter profile used for exporting data via MQTT. Requires further configuration which can easily be accomplished using environment variable overrides

Required:

- `WRITABLE_PIPELINE_FUNCTIONS_MQTTEXPORT_PARAMETERS_BROKERADDRESS: [Your Broker Address]`


    There are many optional functions and parameters provided in this profile. See the [complete profile](https://github.com/edgexfoundry/app-service-configurable/blob/v2.0.0/res/mqtt-export/configuration.toml) for more details

### push-to-core 

Example profile demonstrating how to use the PushToCore function. Provided as an exmaple that can be copied and modified to create new custom profile. See the [complete profile](https://github.com/edgexfoundry/app-service-configurable/blob/v2.0.0/res/push-to-core/configuration.toml) for more details

Requires further configuration which can easily be accomplished using environment variable overrides

Required:

- `WRITABLE_PIPELINE_FUNCTIONS_PUSHTOCORE_PROFILENAME: [Your Event's profile name]`
- `WRITABLE_PIPELINE_FUNCTIONS_PUSHTOCORE_DEVICENAME: [Your Event's device name]`
- `WRITABLE_PIPELINE_FUNCTIONS_PUSHTOCORE_SOURCENAME: [Your Event's source name]`
- `WRITABLE_PIPELINE_FUNCTIONS_PUSHTOCORE_RESOURCENAME: [Your Event reading's resource name]`
- `WRITABLE_PIPELINE_FUNCTIONS_PUSHTOCORE_VALUETYPE: [Your Event reading's value type]`
- `WRITABLE_PIPELINE_FUNCTIONS_PUSHTOCORE_MEDIATYPE: [Your Event binary reading's media type]` 
  - Required only when `ValueType` is `Binary`

### sample

Sample profile with all available functions declared and a sample pipeline. Provided as a sample that can be copied and modified to create new custom profiles. See the [complete profile](https://github.com/edgexfoundry/app-service-configurable/blob/v2.0.0/res/sample/configuration.toml) for more details

### functional-tests

Profile used for the TAF functional testing  

### external-mqtt-trigger

Profile used for the TAF functional testing  of external MQTT Trigger

## What if my input data isn't an EdgeX Event ?

The default `TargetType` for data flowing into the functions pipeline is an EdgeX Event DTO. There are cases when this incoming data might not be an EdgeX Event DTO. There are two setting that configure the TargetType to non-Event data.

### UseTargetTypeOfByteArray

 In these cases the `Pipeline` can be configured using `UseTargetTypeOfByteArray=true` to set the `TargetType` to be a byte array/slice, i.e. `[]byte`. The first function in the pipeline must then be one that can handle the `[]byte` data. The **compression**,  **encryption** and **export** functions are examples of pipeline functions that will take input data that is `[]byte`. 

!!! example "Example - Configure the functions pipeline to **compress**, **encrypt** and then **export** the `[]byte` data via HTTP "
    ```toml
    [Writable]
      LogLevel = "DEBUG"
      [Writable.Pipeline]
        UseTargetTypeOfByteArray = true
        ExecutionOrder = "Compress, Encrypt, HTTPExport"
        [Writable.Pipeline.Functions.Compress]
          [Writable.Pipeline.Functions.Compress.Parameters]
          Alogrithm = "gzip"
        [Writable.Pipeline.Functions.Encrypt]
          [Writable.Pipeline.Functions.Encrypt.Parameters]
            Algorithm = "aes"
            Key = "aquqweoruqwpeoruqwpoeruqwpoierupqoweiurpoqwiuerpqowieurqpowieurpoqiweuroipwqure"
            InitVector = "123456789012345678901234567890"
        [Writable.Pipeline.Functions.HTTPExport]
          [Writable.Pipeline.Functions.HTTPExport.Parameters]
          Method = "post"
          Url = "http://my.api.net/edgexdata"
          MimeType = "application/text"
    ```

If along with this pipeline configuration, you also configured the `Trigger` to be `http` trigger,  you could then send any data to the app-service-configurable' s `/api/v2/trigger` endpoint and have it compressed, encrypted and sent to your configured URL above.

!!! example "Example - HTTP Trigger configuration"
    ``` toml
    [Trigger]
    Type="http"
    ```

### UseTargetTypeOfMetric

!!! edgey "Edgex 2.2"
    New for EdgeX 2.2 is the `UseTargetTypeOfMetric` setting

This setting when set to true will cause the `TargeType` to be `&dtos.Metric{}` and is meant to be used in conjunction with the new `ToLineProtocol` function. See [ToLineProtocol](#tolineprotocol) section below for more details. In addition the `Trigger` `SubscribeTopics`must be set to `"edgex/telemetry/#"` so that the function receives the metric data from the other services.

!!! example - "Example -  UseTargetTypeOfMetric "
    ```
      [Writable.Pipeline]
      UseTargetTypeOfMetric  = true
      ExecutionOrder = "ToLineProtocol, ..."
      ...
          [Writable.Pipeline.Functions.ToLineProtocol]
          [Writable.Pipeline.Functions.ToLineProtocol.Parameters]
          Tags = "" # optional comma separated list of additional tags to add to the metric in to form "tag:value,..."
      ...
      [Trigger]
      Type="edgex-messagebus"
      [Trigger.EdgexMessageBus]
      ...
        [Trigger.EdgexMessageBus.SubscribeHost]
        ...
        SubscribeTopics="edgex/telemetry/#"
    ```

## Multiple Instances of a Function

!!! edgey "Edgex 2.0"
    New for EdgeX 2.0

Now multiple instances of the same configurable pipeline function can be specified,  configured differently and used together in the functions pipeline. Previously the function names specified in the `[Writable.Pipeline.Functions]` section had to match a built-in configurable pipeline function name exactly. Now the names specified only need to start with a built-in configurable pipeline function name. See the [HttpExport](#httpexport) section below for an example.

## Available Configurable Pipeline Functions

Below are the functions that are available to use in the configurable pipeline function pipeline (`[Writable.Pipeline]`) section of the configuration. The function names below can be added to the `Writable.Pipeline.ExecutionOrder` setting (comma separated list) and must also be present or added to the `[Writable.Pipeline.Functions]` section as `[Writable.Pipeline.Functions.{FunctionName}]`. The functions will also have the `[Writable.Pipeline.Functions.{FunctionName}.Parameters]` section where the function's parameters are configured. Please refer to the [Getting Started](#getting-started) section above for an example.

!!! note
    The `Parameters` section for each function is a key/value map of `string` values. So even tough the parameter is referred to as an Integer or Boolean, it has to be specified as a valid string representation, e.g. "20" or "true".

Please refer to the function's detailed documentation by clicking the function name below.

### [AddTags](../BuiltIn/#tags)

**Parameters**

- `tags` - String containing comma separated list of tag key/value pairs. The tag key/value pairs are colon seperated

!!! example
    ```toml
        [Writable.Pipeline.Functions.AddTags]
          [Writable.Pipeline.Functions.AddTags.Parameters]
          tags = "GatewayId:HoustonStore000123,Latitude:29.630771,Longitude:-95.377603"
    ```

### [Batch](../BuiltIn/#batching)

**Parameters**

- `Mode`- The batch mode to use. can be 'bycount', 'bytime' or 'bytimecount'
- `BatchThreshold` - Number of items to batch before sending batched items to the next function in the pipeline. Used with  'bycount' and 'bytimecount' modes
- `TimeInterval` - Amount of time to batch before sending batched items to the next function in the pipeline. Used with  'bytime' and 'bytimecount' modes
- `IsEventData` - If true, specifies that the data being batched is `Events` and to un-marshal the batched data to `[]Event` prior to returning the batched data. By default the batched data returned is `[][]byte`
- `MergeOnSend` - If true, specifies that the data being batched is to be merged to a single `[]byte` prior to returning the batched data. By default the batched data returned is `[][]byte`

!!! example
    ```toml
        [Writable.Pipeline.Functions.Batch]
          [Writable.Pipeline.Functions.Batch.Parameters]
          Mode = "bytimecount" # can be "bycount", "bytime" or "bytimecount"
          BatchThreshold = "30"
          TimeInterval = "60s"
          IsEventData = "false"
          MergeOnSend = "false"     
    or
    	[Writable.Pipeline.Functions.Batch]
          [Writable.Pipeline.Functions.Batch.Parameters]
          Mode = "bytimecount" # can be "bycount", "bytime" or "bytimecount"
          BatchThreshold = "30"
          TimeInterval = "60s"
          IsEventData = "true"
          MergeOnSend = "false"    
    or
        [Writable.Pipeline.Functions.Batch]
          [Writable.Pipeline.Functions.Batch.Parameters]
          Mode = "bytimecount" # can be "bycount", "bytime" or "bytimecount"
          BatchThreshold = "30"
          TimeInterval = "60s"
          IsEventData = "false"
          MergeOnSend = "true"
    ```

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the `BatchByCount`, `BatchByTime`, and `BatchByTimeCount` configurable pipeline functions have been replaced by single `Batch` configurable pipeline function with additional `Mode` parameter.

!!! edgey "EdgeX 2.1"
    The `IsEventData` setting is new for EdgeX 2.1

!!! edgey "EdgeX 2.1"
    The `MergeOnSend` setting is new for EdgeX 2.2

### [Compress](../BuiltIn/#compression)

**Parameters**

- `Algorithm ` - Compression algorithm to use.  Can be 'gzip' or 'zlib'

!!! example
    ```toml
        [Writable.Pipeline.Functions.Compress]
          [Writable.Pipeline.Functions.Compress.Parameters]
          Algorithm = "gzip"
    ```

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the `CompressWithGZIP` and `CompressWithZLIB` configurable pipeline functions have been replaced by the single `Compress` configurable pipeline function with additional `Algorithm ` parameter.

### [Encrypt](../BuiltIn/#dataprotection)
**Parameters**

- `Algorithm` - AES256
- `SecretPath` - (required for AES256) Path in the `Secret Store` where the encryption key is located.
- `SecretName` - (required for AES256) Name of the secret for the encryption key in the `Secret Store`.

!!! example
    ```toml
        # Encrypt with key pulled from Secret Store
        [Writable.Pipeline.Functions.Encrypt]
          [Writable.Pipeline.Functions.Encrypt.Parameters]
          Algorithm = "aes256"
          SecretPath = "aes"
          SecretName = "key"
    ```

### [FilterByDeviceName](../BuiltIn/#by-device-name)

**Parameters**

- `DeviceNames` - Comma separated list of device names for filtering
- `FilterOut`- Boolean indicating if the data matching the device names should be filtered out or filtered for.

!!! example
    ```toml
        [Writable.Pipeline.Functions.FilterByDeviceName]
          [Writable.Pipeline.Functions.FilterByDeviceName.Parameters]
            DeviceNames = "Random-Float-Device,Random-Integer-Device"
            FilterOut = "false"
    ```
### [FilterByProfileName](../BuiltIn/#by-profile-name)

**Parameters**

- `ProfileNames` - Comma separated list of profile names for filtering
- `FilterOut`- Boolean indicating if the data matching the profile names should be filtered out or filtered for.

!!! example
    ```toml
        [Writable.Pipeline.Functions.FilterByProfileName]
          [Writable.Pipeline.Functions.FilterByProfileName.Parameters]
          ProfileNames = "Random-Float-Device, Random-Integer-Device"
          FilterOut = "false"
    ```

!!! edgey "EdgeX 2.0"
    The `FilterByProfileName` configurable pipeline function is new for EdgeX 2.0 

### [FilterByResourceName](../BuiltIn/#by-resource-name)

**Parameters**

- `ResourceName` - Comma separated list of reading resource names for filtering
- `FilterOut`- Boolean indicating if the readings matching the resource names should be filtered out or filtered for.

!!! example
    ```toml
        [Writable.Pipeline.Functions.FilterByResourceName]
          [Writable.Pipeline.Functions.FilterByResourceName.Parameters]
           ResourceNames = "Int8, Int64"
            FilterOut = "true"
    ```


!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the `FilterByValueDescriptor` configurable pipeline function has been renamed to `FilterByResourceName` and parameter names adjusted. 

### [FilterBySourceName](../BuiltIn/#by-source-name)

**Parameters**

- `SourceNames` - Comma separated list of source names for filtering. Source name is either the device command name or the resource name that created the Event
- `FilterOut`- Boolean indicating if the data matching the device names should be filtered out or filtered for.

!!! example
    ```toml
        [Writable.Pipeline.Functions.FilterBySourceName]
          [Writable.Pipeline.Functions.FilterBySource.Parameters]
          SourceNames = "Bool, BoolArray"
          FilterOut = "false"
    ```

!!! edgey "EdgeX 2.0"
    The `FilterBySourceName` configurable pipeline function is new for EdgeX 2.0 

### [HTTPExport](../BuiltIn/#http-export)

**Parameters**

- `Method` - HTTP Method to use. Can be `post` or `put`
- `Url` - HTTP endpoint to POST/PUT the data.
- `MimeType` - Optional mime type for the data. Defaults to `application/json` if not set.
- `PersistOnError` - Indicates to persist the data if the POST fails. Store and Forward must also be enabled if this is set to "true".
- `ContinueOnSendError` - For chained multi destination exports, if true continues after send error so next export function executes.
- `ReturnInputData` - For chained multi destination exports if true, passes the input data to next export function.
- `HeaderName` - (Optional) Name of the header key to add to the HTTP header
- `SecretPath` - (Optional) Path of the secret in the `Secret Store` where the header value is stored.
- `SecretName` - (Optional) Name of the secret for the header value in the `Secret Store`.

!!! example
    ```toml
        # Simple HTTP Export
        [Writable.Pipeline.Functions.HTTPExport]
          [Writable.Pipeline.Functions.HTTPExport.Parameters]
          Method = "post" 
          MimeType = "application/xml" 
          Url = "http://my.api.net/edgexdata" 
    ```
    ```toml
        # HTTP Export with secret header data pull from Secret Store
        [Writable.Pipeline.Functions.HTTPExport]
          [Writable.Pipeline.Functions.HTTPExport.Parameters]
          Method = "post" 
          MimeType = "application/xml" 
          Url = "http://my.api.net/edgexdata"
          HeaderName = "MyApiKey" 
          SecretPath = "http" 
          SecretName = "apikey"
    ```
    ```toml
        # Http Export to multiple destinations
        [Writable.Pipeline]
        ExecutionOrder ="HTTPExport1, HTTPExport2"

        [Writable.Pipeline.Functions.HTTPExport1]
          [Writable.Pipeline.Functions.HTTPExport1.Parameters]
          Method = "post" 
          MimeType = "application/xml" 
          Url = "http://my.api1.net/edgexdata2" 
          ContinueOnSendError = "true"
          ReturnInputData = "true"
        [Writable.Pipeline.Functions.HTTPExport2]
          [Writable.Pipeline.Functions.HTTPExport2.Parameters]
          Method = "put" 
          MimeType = "application/xml" 
          Url = "http://my.api2.net/edgexdata2"
    ```

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the `HTTPPost`, `HTTPPostJSON`, `HTTPPostXML`, `HTTPPut`, `HTTPPutJSON`,  and `HTTPPutXML`  configurable pipeline functions have been replaced by the single `HTTPExport` function with additional `Method ` parameter. `ContinueOnSendError` and `ReturnInputData` parameter have been added to support multi destination exports. In addition the `HeaderName` and `SecretName` parameters have replaced the `SecretHeaderName` parameter.

!!! edgey "EdgeX 2.0"
    The capability to chain Http Export functions to export to multiple destinations is new for Edgex 2.0. 

!!! edgey "EdgeX 2.0"
    Multiple instances (configured differently) of the same configurable pipeline function is new for EdgeX 2.0. The function names in the `Writable.Pipeline.Functions` section now only need to start with a built-in configurable pipeline function name, rather than be an exact match.

### [JSONLogic](../BuiltIn/#json-logic)
**Parameters**

- `Rule` - The JSON formatted rule that with be executed on the data by JSONLogic 

!!! example
    ```toml
        [Writable.Pipeline.Functions.JSONLogic]
          [Writable.Pipeline.Functions.JSONLogic.Parameters]
          Rule = "{ \"and\" : [{\"<\" : [{ \"var\" : \"temp\" }, 110 ]}, {\"==\" : [{ \"var\" : \"sensor.type\" }, \"temperature\" ]} ] }"
    ```
### [MQTTExport](../BuiltIn/#mqtt-export)

**Parameters**

- `BrokerAddress` - URL specify the address of the MQTT Broker
- `Topic` - Topic to publish the data
- `ClientId` - Id to use when connecting to the MQTT Broker
- `Qos` - MQTT Quality of Service (QOS) setting to use (0, 1 or 2). Please refer [**here**](https://www.eclipse.org/paho/files/mqttdoc/MQTTClient/html/qos.html) for more details on QOS values
- `AutoReconnect` - Boolean specifying if reconnect should be automatic if connection to MQTT broker is lost
- `Retain` - Boolean  specifying if the MQTT Broker should save the last message published as the “Last Good Message” on that topic.
- `SkipVerify` - Boolean indicating if the certificate verification should be skipped. 
- `PersistOnError` - Indicates to persist the data if the POST fails. Store and Forward must also be enabled if this is set to "true".
- `AuthMode` - Mode of authentication to use when connecting to the MQTT Broker
    - `none` - No authentication required
    - `usernamepassword` - Use username and password authentication. The Secret Store (Vault or [InsecureSecrets](../GeneralAppServiceConfig/#writable-insecuresecrets)) must contain the `username` and `password` secrets.
    - `clientcert` - Use Client Certificate authentication. The Secret Store (Vault or [InsecureSecrets](../GeneralAppServiceConfig/#writable-insecuresecrets)) must contain the `clientkey` and `clientcert` secrets.
    - `cacert` - Use CA Certificate authentication. The Secret Store (Vault or [InsecureSecrets](../GeneralAppServiceConfig/#writable-insecuresecrets)) must contain the `cacert` secret.
- `SecretPath` - Path in the secret store where authentication secrets are stored.

!!! note
        `Authmode=cacert` is only needed when client authentication (e.g. `usernamepassword`) is not required, but a CA Cert is needed to validate the broker's SSL/TLS cert.

!!! example
    ```toml
        # Simple MQTT Export
        [Writable.Pipeline.Functions.MQTTExport]
          [Writable.Pipeline.Functions.MQTTExport.Parameters]
          BrokerAddress = "tcps://localhost:8883"
          Topic = "mytopic"
          ClientId = "myclientid"
    ```
    ```toml
        # MQTT Export with auth credentials pull from the Secret Store
        [Writable.Pipeline.Functions.MQTTExport]
          [Writable.Pipeline.Functions.MQTTExport.Parameters]
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

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the `MQTTSecretSend` configurable pipeline function has been renamed to `MQTTExport` and the deprecated  `MQTTSend` configurable pipeline function has been removed

### [PushToCore](../BuiltIn/#push-to-core-data)

**Parameters**

- `ProfileName` - Profile name to use for the new Event
- `DeviceName` - Device name to use for  the new Event
- `ResourceName` -  Resource name name to use for  the new Event's` SourceName` and Reading's `ResourceName`
- `ValueType` - Value type to use  the new Event Reading's value type
- `MediaType` - Media type to use the new Event Reading's value type. Required when the value type is `Binary`

!!! example
    ```toml
        [Writable.Pipeline.Functions.PushToCore]
          [Writable.Pipeline.Functions.PushToCore.Parameters]
          ProfileName = "MyProfile"
          DeviceName = "MyDevice"
          ResourceName = "SomeResource"
          ValueType = "String"
    ```

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the `ProfileName`, `ValueType` and `MediaType` parameters are new and the `ReadingName` parameter has been renamed to `ResourceName`. 

### [SetResponseData](../BuiltIn/#set-response-data)

**Parameters**

- `ResponseContentType` - Used to specify content-type header for response - optional

!!! example
    ```toml
        [Writable.Pipeline.Functions.SetResponseData]
          [Writable.Pipeline.Functions.SetResponseData.Parameters]
          ResponseContentType = "application/json"
    ```

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the `SetOutputData` configurable pipeline function has been renamed to `SetResponseData` . 

### [Transform](../BuiltIn/#conversion)

**Parameters**

- `Type` - Type of transformation to perform. Can be 'xml' or 'json'

!!! example
    ```toml
        [Writable.Pipeline.Functions.Transform]
          [Writable.Pipeline.Functions.Transform.Parameters]
          Type = "xml"
    ```

!!! edgey "EdgeX 2.0"
    For EdgeX 2.0 the `TransformToJSON` and `TransformToXML` configurable pipeline functions have been replaced by the single `Transform` configurable pipeline function with additional `Type  ` parameter.

### [ToLineProtocol](../BuiltIn/#tolineprotocol)

!!! edgey "EdgeX 2.2"
    `ToLineProtocol` is new for Edgex 2.2

**Parameters**

- `Tags` - optional comma separated list of additional tags to add to the metric in to form "tag:value,..."

!!! example
    ```toml
        [Writable.Pipeline.Functions.ToLineProtocol]
          [Writable.Pipeline.Functions.ToLineProtocol.Parameters]
          Tags = "" # optional comma separated list of additional tags to add to the metric in to form "tag:value,..."
    ```

!!! note
    The new `UseTargetTypeOfMetric` setting must be set to true when using this function. See the [UseTargetTypeOfMetric](#usetargettypeofmetric) section above for more details.

### [WrapIntoEvent](../BuiltIn/#wrap-into-event)

!!! edgey "EdgeX 2.3" 
    The `WrapIntoEvent` configurable pipeline function is new for EdgeX 2.3

**Parameters**

- `ProfileName` - Profile name to use for the new Event
- `DeviceName` - Device name to use for  the new Event
- `ResourceName` -  Resource name name to use for  the new Event's` SourceName` and Reading's `ResourceName`
- `ValueType` - Value type to use  the new Event Reading's value type
- `MediaType` - Media type to use the new Event Reading's value type. Required when the value type is `Binary`

!!! example
    ```toml
        [Writable.Pipeline.Functions.WrapIntoEvent]
          [Writable.Pipeline.Functions.WrapIntoEvent.Parameters]
          ProfileName = "MyProfile"
          DeviceName = "MyDevice"
          ResourceName = "SomeResource"
          ValueType = "String"
          MediaType = ""  # Required only when ValueType=Binary
    ```