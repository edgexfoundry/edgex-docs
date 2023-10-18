---
title: App Service Configurable - Target Type
---

# App Service Configurable - Target Type

The default `TargetType` for data flowing into the functions pipeline is an EdgeX Event DTO. 
There are cases when this incoming data might not be an EdgeX Event DTO. There are two values that TargetType can be 
configured to for non-Event data.

## Raw TargetType

 In these cases the `Pipeline` can be configured using `TargetType="raw"` to set the `TargetType` to be a byte array/slice, i.e. `[]byte`. The first function in the pipeline must then be one that can handle the `[]byte` data. The **compression**,  **encryption** and **export** functions are examples of pipeline functions that will take input data that is `[]byte`. 

!!! example "Example - Configure the functions pipeline to **compress**, **encrypt** and then **export** the `[]byte` data via HTTP "
    ```yaml
    Writable:
      Pipeline:
        TargetType: "raw"
        ExecutionOrder: "Compress, Encrypt, HTTPExport"
        Functions:
          Compress:
            Parameters:
              Algorithm: "gzip"
          Encrypt:
            Parameters:
              Algorithm: "aes256" 
              SecretName: "aes"
              SecretValueKey: "key"
          HTTPExport:
            Parameters:
              Method: "post"
              Url: "http://my.api.net/edgexdata"
              MimeType: "application/text"
    ```

If along with this pipeline configuration, you also configured the `Trigger` to be `http` trigger,  you could then send any data to the app-service-configurable's `/api/{{api_version}}/trigger` endpoint and have it compressed, encrypted and sent to your configured URL above.

!!! example "Example - HTTP Trigger configuration"
    ```yaml
    Trigger:
      Type: "http"
    ```

## Metric TargetType

This setting when set to true will cause the `TargeType` to be `&dtos.Metric{}` and is meant to be used in conjunction with the new `ToLineProtocol` function. See [ToLineProtocol](AvailablePipelineFunctions.md#tolineprotocol) section below for more details. In addition, the `Trigger` `SubscribeTopics`must be set to `"edgex/telemetry/#"` so that the function receives the metric data from the other services.

!!! example - "Example -  Metric TargetType "
    ```yaml
    Writable:
      Pipeline:
        TargetType: "metric"
        ExecutionOrder: "ToLineProtocol, ..."
      ...
        Functions:
          ToLineProtocol:
            Parameters:
              Tags: "" # optional comma separated list of additional tags to add to the metric in to form "tag:value,..."
      ...
     Trigger:
       SubscribeTopics: telemetry/#"
    ```