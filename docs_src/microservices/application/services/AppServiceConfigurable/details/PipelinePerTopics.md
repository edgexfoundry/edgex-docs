---
title: App Service Configurable - Pipeline Per Topics
---

# App Service Configurable - Pipeline Per Topics

The pipeline configuration in [Getting Started](../../../GettingStarted.md) section is the preferred way if your use case only 
requires a single functions pipeline. For use cases that require multiple functions pipelines in order to process the data 
differently based on the `profile`, `device` or `source` for the Event, there is the Pipeline Per Topics feature. 
This feature allows multiple pipelines to be configured in the `Writable.Pipeline.PerTopicPipelines` section. 
This section is a map of pipelines. The map key must be unique, but the value isn't used, so it can be any value. 

Each pipeline is defined by the following configuration elements:

| Element        | Value             | Description                                                                                                                                                                                                                |
|----------------|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Id             | unique ID         | This is the unique ID given to each pipeline                                                                                                                                                                               |
| Topics         | List of topics    | Comma separated list of topics that control when the pipeline is executed. See the [Pipeline Per Topics](../../../sdk/api/BuiltInPipelineFunctions.md) advanced topic section for details on using wildcards in the topic. |
| ExecutionOrder | List of functions | Comma separated list of function names, in order, that the pipeline will execute. Same as `ExecutionOrder` in the above example in the  [Getting Started](../GettingStarted.md) section                                    |

!!! example "Example - Writable.Pipeline.PerTopicPipelines"
    In this example Events from the device  `Random-Float-Device` are transformed to JSON and then HTTP exported. At the same time, Events for the source `Int8`  are transformed to XML and then HTTP exported to same endpoint. Note the custom naming for `TransformJson` and `TransformXml`. This is taking advantage of the [Multiple Instances of a Function](AvailablePipelineFunctions.md#multiple-instances-of-a-function) described below.

    ```yaml
    Writable:
      Pipeline:
        PerTopicPipelines:
          float:
            Id: float-pipeline
            Topics: "edgex/events/device/+/Random-Float-Device/#, edgex/events/device/+/Random-Integer-Device/#"
            ExecutionOrder: "TransformJson, HTTPExport"
          int8:
            Id: int8-pipeline
            Topic: edgex/events/device/+/+/+/Int8
            ExecutionOrder: "TransformXml, HTTPExport"
        Functions:
          FilterByDeviceName:
            Parameters:
              FilterValues: "Random-Float-Device, Random-Integer-Device"
          TransformJson:
            Parameters:
              Type: json
          TransformXml:
            Parameters:
              Type: xml
          HTTPExport:
            Parameters:
              Method: post
              MimeType: application/xml
              Url: "http://my.api.net/edgexdata"
    ```

!!! note
    The `Pipeline Per Topics` feature is targeted for EdgeX MessageBus and External MQTT triggers, but can be used with Custom or HTTP triggers. When used with the HTTP trigger the incoming topic will always be `blank`, so the pipeline's topics must contain a single topic set to the `#` wildcard so that all messages received are processed by the pipeline.
