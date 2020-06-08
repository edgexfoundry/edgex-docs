# App Service Configurable

App-Service-Configurable is provided as an easy way to get started with processing data flowing through EdgeX. This service leverages the [App Functions SDK](https://github.com/edgexfoundry/app-functions-sdk-go) and provides a way for developers to use configuration instead of having to compile standalone services to utilize built in functions in the SDK. For a full list of supported/built-in functions view the `Transforms` documentation in the [Application Functions SDK](./ApplicationFunctionsSDK.md#built-in-transformsfunctions) section. 

## Getting Started 

To get started with the configurable app service, you'll want to start by determining which functions are required in your pipeline. Using a simple example.
let's assume you wish to use the following functions from the SDK:

1. [FilterByDeviceName](./ApplicationFunctionsSDK.md#filtering) -   to filter events for a specific device.
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

Next, each function and its required information is listed. Each function typically has associated Parameters that must be configured to properly execute the function as designated by `[Writable.Pipeline.Functions.{FunctionName}.Parameters]`. Knowing which parameters are required for each function, can be referenced by taking a look at the `Transforms` documentation located in the [Application Functions SDK](./ApplicationFunctionsSDK.md#built-in-transformsfunctions) section. In a few cases, such as `TransformToXML`, `TransformToJSON`, or `SetOutputData`, there are no parameters required.

!!! note
    By default, the configuration provided is set to use MessageBus as a trigger from CoreData. This means you must have EdgeX Running with devices sending data in order to trigger the pipeline. You can also change the trigger to be HTTP. For more on triggers, view the `Triggers`documentation located in the [Triggers](./Triggers.md) section.

That's it! Now we can run/deploy this service and the functions pipeline will process the data with functions we've defined.

## Environment Variable Overrides For Docker

EdgeX services no longer has docker specific profiles. They now rely on environment variable overrides in the docker compose files for the docker specific differences. The following environment settings are required in the compose files when using App Service Configurable.

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
      edgex-network:
        aliases:
          - edgex-app-service-configurable-rules
    depends_on:
      - data
```

!!! note
    **App Service Configurable** is designed to be run multiple times each with different profiles. This is why in the above example the name `edgex-app-service-configurable-rules` is used for the instance running the `rules-engine` profile.

## Deploying Multiple Instances using profiles

App Service Configurable was designed to be deployed as multiple instances with different purposes. Since the function pipeline is specified in the `configuration.toml` file, we can use this as a way to run each instance with a different function pipeline. App Service Configurable does not have the standard default configuration at `/res/configuration.toml`. This default configuration has been moved to the `sample` profile. This forces you to specify the profile for the configuration you would like to run. The profile is specified using the `-p/--profile=[profilename]` command line option or the `EDGEX_PROFILE=[profilename]` environment variable override. The profile name selected is used in the service key (`AppService-[profile name]`) to make each instance unique, e.g. `AppService-sample` when specifying `sample` as the profile.

!!! note
    If you need to run multiple instances with the same profile, e.g. `http-export`, but configured differently, you will need to override the service key with a custom name for one or more of the services. This is done with the `-sk/-serviceKey` command-line option or the `EDGEX_SERVICE_KEY` environment variable. See the `Command-line Options` and `Environment Overrides` documentation located in the [Application Functions SDK](./ApplicationFunctionsSDK.md#command-line-options) section for more detail.

The following profiles and their purposes are provided with App Service Configurable. 

- **blackbox-tests** - Profile used for black box testing the SDK 
- **http-export** - Starter profile used for exporting data via HTTP.  Requires further configuration which can easily be accomplished using environment variable overrides
    - Required:
        - `Writable_Pipeline_Functions_HTTPPostJSON_Parameters_url: [Your URL]`

    - Optional: 
``` yaml
environment:
    - Writable_Pipeline_Functions_HTTPPostJSON_Parameters_persistOnError: ["true"/"false"]
    - Writable_Pipeline_Functions_FilterByDeviceName_Parameters_DeviceNames: "[comma separated list]"
    - Writable_Pipeline_Functions_FilterByValueDescriptor_Parameters_ValueDescriptors: "[comma separated list]"
    - Writable_Pipeline_Functions_FilterByValueDescriptor_Parameters_FilterOut: ["true"/"false"]
```
- **mqtt-export** - Starter profile used for exporting data via MQTT. Requires further configuration which can easily be accomplished using environment variable overrides
    - Required:
        - `Writable_Pipeline_Functions_MQTTSend_Addressable_Address: [Your Address]`

    - Optional: 

``` yaml
environment:
  - Writable_Pipeline_Functions_MQTTSend_Addressable_Port: ["your port"]
  - Writable_Pipeline_Functions_MQTTSend_Addressable_Protocol: [tcp or tcps]
  - Writable_Pipeline_Functions_MQTTSend_Addressable_Publisher: [your name]
  - Writable_Pipeline_Functions_MQTTSend_Addressable_User: [your username]
  - Writable_Pipeline_Functions_MQTTSend_Addressable_Password: [your password]
  - Writable_Pipeline_Functions_MQTTSend_Addressable_Topic: [your topic]

  - Writable_Pipeline_Functions_MQTTSend_Parameters_qos: ["your quality or service"]
  - Writable_Pipeline_Functions_MQTTSend_Parameters_key: [your Key]  
  - Writable_Pipeline_Functions_MQTTSend_Parameters_cert: [your Certificate]
  - Writable_Pipeline_Functions_MQTTSend_Parameters_autoreconnect: ["true" or "false"]
  - Writable_Pipeline_Functions_MQTTSend_Parameters_retain: ["true" or "false"]
  - Writable_Pipeline_Functions_MQTTSend_Parameters_persistOnError: ["true" or "false"]
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