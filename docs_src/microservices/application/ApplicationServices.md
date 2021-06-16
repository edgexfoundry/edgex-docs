# Application Services

![image](ApplicationServices.png)

Application Services are a means to get data from EdgeX Foundry to be processed at the edge and/or sent to external systems (be it analytics package, enterprise or on-prem application, cloud systems like Azure IoT, AWS IoT, or Google IoT Core, etc.). Application Services provide the means for data to be prepared (transformed, enriched, filtered, etc.) and groomed (formatted, compressed, encrypted, etc.) before being sent to an endpoint of choice or published back to other Application Service to consume. The export endpoints supported out of the box today include HTTP and MQTT endpoints, but custom endpoints can be implemented along side the existing functionality.

Application Services are based on the idea of a "Functions Pipeline". A functions pipeline is a collection of functions that process messages (in this case EdgeX event/reading messages) in the order that you've specified. Triggers seed the first function in the pipeline with the data received by the Application Service. A trigger is something like a message landing in a watched message queue. The most commonly used Trigger is the MessageBus Trigger. See the [Triggers](./Triggers.md) section for more details

![image](TriggersFunctions.png)

An Applications Functions Software Development Kit (or `App Functions SDK`) is available to help create Application Services. Currently the only SDK supported language is Golang, with the intention that community developed and supported SDKs may come in the future for other languages. The SDK is available as a Golang module to remain operating system (OS) agnostic and to comply with the latest EdgeX guidelines on dependency management.

Any application built on top of the Application Functions SDK is considered an App Service. This SDK is provided to help build Application Services by assembling triggers, pre-existing functions and custom functions of your making into a pipeline.

## Standard Functions

As mentioned, an Application Service is a function pipeline. The SDK provides some standard functions that can be used in a functions pipeline. In the future, additional functions will be provided "standard" or in other words provided with the SDK. Additionally, developers can implement their own custom functions and add those to their Application Service functions pipeline.

![image](SDKFunctions.png)

One of the most common use cases for working with data that comes from the MessageBus is to filter data down to what is relevant for a given application and to format it. To help facilitate this, six primary functions  are included in the SDK. 

- The first is the `FilterByProfileName` function which will remove events that do or do not match the configured `ProfileNames` and execution of the pipeline will cease if no event remains after filtering. 
- The second is the `FilterByDeviceName` function which will remove events that do or do not match the configured `DeviceNames` and execution of the pipeline will cease if no event remains after filtering.  
- The third is the `FilterBySourceName` function which will remove events that do or do not match the configured `SourceNames` and execution of the pipeline will cease if no event remains after filtering. A `SourceName` is the name of the source (command or resource) that the Event was created from. 
- The fourth is the `FilterByResourceName` which exhibits the same behavior as `DeviceNameFilter` except filtering the event's `Readings` on `ResourceName` instead of `DeviceName`. Execution of the pipeline will cease if no readings remain after filtering. 
- The fifth and sixth provided functions in the SDK transform the data received to either XML or JSON by calling `XMLTransform` or `JSONTransform`.

!!! edgey "EdgeX 2.0" 
    The `FilterByProfileName` and `FilterBySourceName` pipeline functions are new in EdgeX 2.0 with the addition of the `ProfileName` and `SourceName` on the V2 `Event` DTO.   `FilterByResourceName` replaces the `FileterByValueDescriptor` pipeline function in EdgeX 2.0 with the change of `Name` to `ResourceName` on the V2 `Reading` DTO. This function serves the same purpose of filtering Event Readings.

Typically, after filtering and transforming the data as needed, exporting is the last step in a pipeline to ship the data where it needs to go. There are three primary functions included in the SDK to help facilitate this. The first are the`HTTPPost/HTTPPut` functions that will POST/PUT the provided data to a specified endpoint, and the third is an `MQTTSecretSend()` function that will publish the provided data to an MQTT Broker as specified in the configuration.

See [Built-in Functions](./BuiltIn.md) section for full list of SDK supplied functions 

!!! Note
    The App SDK provides much more functionality than just filtering, formatting and exporting. The above simple example is provided to demonstrate how the functions pipeline works. With the ability to write your custom pipeline functions, your custom application services can do what ever your use case demands.

There are three primary triggers that have been included in the SDK that initiate the start of the function pipeline. First is the HTTP Trigger via a POST to the endpoint `/api/v2/trigger` with the EdgeX Event data as the body. Second is the EdgeX MessageBus Trigger with connection details as specified in the configuration and the third it the External MQTT Trigger with connection details as specified in the configuration. See the [Triggers](./Triggers.md) section for full list of available `Triggers`

Finally, data may be sent back to the Trigger response by calling `.SetResponseData()` on the context. If the trigger is HTTP, then it will be an HTTP Response. If the trigger is EdgeX MessageBus, then it will be published to the configured host and publish topic. If the trigger is External MQTT, then it will be published to the configured publish topic.

